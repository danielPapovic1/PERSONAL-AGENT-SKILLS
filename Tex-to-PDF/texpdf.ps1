#!/usr/bin/env pwsh
param(
  [Parameter(Position = 0)]
  [Alias("Input")]
  [string]$InputPath,

  [ValidateSet("xelatex", "lualatex")]
  [string]$Engine = "xelatex",

  [Alias("Output")] 
  [string]$OutputPath,

  [int]$Passes = 2,

  [int]$Timeout = 180,

  [switch]$KeepBuildDir
)

$ErrorActionPreference = "Stop"

if (-not $InputPath) {
  Write-Host "Usage:"
  Write-Host "  .\texpdf.ps1 path\to\resume.tex [options]"
  Write-Host ""
  Write-Host "Examples:"
  Write-Host "  .\texpdf.ps1 base-tex\BASE-tex-resume.tex"
  Write-Host "  .\texpdf.ps1 Jobs\Rocket-Fall-2026\rocket-resume.tex -Engine xelatex"
  Write-Host "  .\texpdf.ps1 Jobs\Rocket-Fall-2026\rocket-resume.tex -Output Outputs\rocket-resume.pdf"
  exit 1
}

function Resolve-ExistingTexFile {
  param([string]$PathValue)

  $resolved = (Resolve-Path -LiteralPath $PathValue -ErrorAction Stop).Path

  if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
    throw "Input path is not a file: $resolved"
  }

  if ([System.IO.Path]::GetExtension($resolved).ToLowerInvariant() -ne ".tex") {
    throw "Input file must be a .tex file: $resolved"
  }

  return $resolved
}

function Get-EngineCandidates {
  param([string]$EngineName)

  $candidates = New-Object System.Collections.Generic.List[string]
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  function Add-Candidate {
    param([string]$PathValue)
    if ($PathValue -and -not $seen.Contains($PathValue)) {
      [void]$seen.Add($PathValue)
      $candidates.Add($PathValue)
    }
  }

  $pathMatch = Get-Command $EngineName -ErrorAction SilentlyContinue
  if ($pathMatch) {
    Add-Candidate $pathMatch.Source
  }

  if ($env:LOCALAPPDATA) {
    Add-Candidate (Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64\$EngineName.exe")
  }

  if (${env:ProgramFiles}) {
    Add-Candidate (Join-Path ${env:ProgramFiles} "MiKTeX\miktex\bin\x64\$EngineName.exe")
  }

  if (${env:ProgramFiles(x86)}) {
    Add-Candidate (Join-Path ${env:ProgramFiles(x86)} "MiKTeX\miktex\bin\x64\$EngineName.exe")
  }

  $homeDir = [Environment]::GetFolderPath("UserProfile")
  if ($homeDir) {
    Add-Candidate (Join-Path $homeDir ".miktex\texmfs\install\miktex\bin\x64\$EngineName.exe")
    Add-Candidate (Join-Path $homeDir "bin\$EngineName")
    Add-Candidate (Join-Path $homeDir ".local\bin\$EngineName")
  }

  foreach ($unixCandidate in @(
    "/Library/TeX/texbin/$EngineName",
    "/usr/local/bin/$EngineName",
    "/opt/homebrew/bin/$EngineName",
    "/opt/local/bin/$EngineName",
    "/usr/bin/$EngineName",
    "/bin/$EngineName",
    "/snap/bin/$EngineName"
  )) {
    Add-Candidate $unixCandidate
  }

  foreach ($searchRoot in @("/usr/local", "/opt", "/Applications", "$homeDir/.miktex", "$homeDir/.local")) {
    if ($searchRoot -and (Test-Path -LiteralPath $searchRoot -PathType Container)) {
      Get-ChildItem -LiteralPath $searchRoot -Recurse -File -Filter $EngineName -ErrorAction SilentlyContinue |
        Select-Object -First 5 |
        ForEach-Object { Add-Candidate $_.FullName }

      Get-ChildItem -LiteralPath $searchRoot -Recurse -File -Filter "$EngineName.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 5 |
        ForEach-Object { Add-Candidate $_.FullName }
    }
  }

  return $candidates
}

function Find-LatexEngine {
  param([string]$EngineName)

  foreach ($candidate in (Get-EngineCandidates $EngineName)) {
    if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
      return $candidate
    }
  }

  return $null
}

function Show-MissingEngineMessage {
  param([string]$EngineName)

  Write-Host "Could not find LaTeX engine: $EngineName"
  Write-Host ""
  Write-Host "The build has been stopped. Install MiKTeX or another TeX distribution, then rerun the command."
  Write-Host ""
  Write-Host "Expected one of these engine executables:"
  foreach ($candidate in (Get-EngineCandidates $EngineName)) {
    if ($candidate) {
      Write-Host "  $candidate"
    }
  }
  Write-Host ""
  Write-Host "After installing MiKTeX, verify with:"
  Write-Host "  $EngineName --version"
}

function Get-LogTail {
  param(
    [string]$PathValue,
    [int]$Lines = 40
  )

  if (Test-Path -LiteralPath $PathValue -PathType Leaf) {
    return (Get-Content -LiteralPath $PathValue -Tail $Lines) -join [Environment]::NewLine
  }

  return ""
}

function Get-MissingPackageMessage {
  param([string]$LogPath)

  if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
    return $null
  }

  $logText = Get-Content -LiteralPath $LogPath -Raw
  $patterns = @(
    '! LaTeX Error: File `([^'']+)'' not found\.',
    'File `([^'']+\.sty)'' not found\.',
    'LaTeX Error: File `([^'']+)'' not found\.'
  )

  foreach ($pattern in $patterns) {
    $match = [regex]::Match($logText, $pattern)
    if ($match.Success) {
      $missingFile = $match.Groups[1].Value
      $packageName = [System.IO.Path]::GetFileNameWithoutExtension($missingFile)

      return @"
Missing LaTeX package or file: $missingFile

The build has been stopped. Install the missing package, then rerun the command.

MiKTeX install command:
  & "`$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\miktex.exe" packages install $packageName
"@
    }
  }

  return $null
}

function ConvertTo-ArgumentString {
  param([string[]]$Arguments)

  $quoted = foreach ($argument in $Arguments) {
    if ($argument -match '[\s"]') {
      '"' + ($argument -replace '"', '\"') + '"'
    } else {
      $argument
    }
  }

  return ($quoted -join " ")
}

if ($Passes -lt 1) {
  throw "-Passes must be at least 1."
}

if ($Timeout -lt 30) {
  throw "-Timeout must be at least 30 seconds."
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$inputFile = Resolve-ExistingTexFile $InputPath
$inputDirectory = Split-Path -Parent $inputFile
$inputName = Split-Path -Leaf $inputFile
$inputStem = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)

if ($OutputPath) {
  $outputFile = [System.IO.Path]::GetFullPath($OutputPath)
  if ([System.IO.Path]::GetExtension($outputFile).ToLowerInvariant() -ne ".pdf") {
    throw "Output path must end in .pdf: $outputFile"
  }
} else {
  $outputFile = Join-Path (Join-Path $repoRoot "Outputs") "$inputStem.pdf"
}

$outputDirectory = Split-Path -Parent $outputFile
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

if ($KeepBuildDir) {
  $buildDir = Join-Path $outputDirectory ".$inputStem-build"
  New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
  $deleteBuildDir = $false
} else {
  $buildDir = Join-Path $outputDirectory ".$inputStem-build-$([System.Guid]::NewGuid().ToString('N'))"
  New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
  $deleteBuildDir = $true
}

$enginePath = Find-LatexEngine $Engine
if (-not $enginePath) {
  Show-MissingEngineMessage $Engine
  exit 127
}

$engineArgs = @(
  "-interaction=nonstopmode",
  "-halt-on-error",
  "-file-line-error",
  "-output-directory=$buildDir",
  $inputName
)

if ($enginePath.ToLowerInvariant().Contains("miktex")) {
  $engineArgs = @("-enable-installer") + $engineArgs
}

try {
  for ($pass = 1; $pass -le $Passes; $pass++) {
    Write-Host "Running LaTeX pass $pass/$Passes..."

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $enginePath
    $startInfo.Arguments = ConvertTo-ArgumentString $engineArgs
    $startInfo.WorkingDirectory = $inputDirectory
    $startInfo.UseShellExecute = $false

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()

    if (-not $process.WaitForExit($Timeout * 1000)) {
      Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
      Write-Host "LaTeX timed out after $Timeout seconds. The build process was stopped."
      Write-Host "If MiKTeX was installing packages, rerun the command after installation finishes."
      exit 124
    }

    $exitCode = $process.ExitCode
    $process.Dispose()

    if ($exitCode -ne 0) {
      $logPath = Join-Path $buildDir "$inputStem.log"
      $missingPackageMessage = Get-MissingPackageMessage $logPath
      if ($missingPackageMessage) {
        Write-Host $missingPackageMessage
        exit $exitCode
      }

      $tail = Get-LogTail $logPath
      Write-Host "LaTeX failed with exit code $exitCode. Log: $logPath"
      Write-Host $tail
      exit $exitCode
    }
  }

  $generatedPdf = Join-Path $buildDir "$inputStem.pdf"
  if (-not (Test-Path -LiteralPath $generatedPdf -PathType Leaf)) {
    throw "LaTeX finished but did not create the expected PDF: $generatedPdf"
  }

  Copy-Item -LiteralPath $generatedPdf -Destination $outputFile -Force
  Write-Host "Wrote $outputFile"
} finally {
  if ($deleteBuildDir -and (Test-Path -LiteralPath $buildDir)) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
  }
}
