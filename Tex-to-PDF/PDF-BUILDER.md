# PDF Builder Flow

This project builds PDFs from LaTeX by using a small PowerShell command around MiKTeX.

## Requirement

Install MiKTeX on Windows so these commands are available on `PATH`:

```powershell
xelatex
lualatex
pdflatex
```

Verify after install:

```powershell
miktex --version 
xelatex --version 
lualatex --version 
```

## How It Works

The `texpdf.ps1` command does not render LaTeX itself. It:

1. Accepts a `.tex` file through `--input`.
2. Finds a MiKTeX engine such as `xelatex` or `lualatex`.
3. Runs the engine with `subprocess`.
4. Copies the generated `.pdf` to the output path.
5. Copies the generated PDF into `Outputs\` or a custom output path.

## Command

```powershell
.\texpdf.ps1 path\to\resume.tex -Engine xelatex
```

Use `lualatex` instead if the resume compiles better with LuaLaTeX:

```powershell
.\texpdf.ps1 path\to\resume.tex -Engine lualatex
```
