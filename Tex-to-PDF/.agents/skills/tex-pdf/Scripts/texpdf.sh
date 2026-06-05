#!/usr/bin/env bash
set -u

input_path=""
engine="xelatex"
output_path=""
passes=2
timeout_seconds=180
keep_build_dir=0 

print_usage() {
  cat <<'EOF'
Usage:
  ./texpdf.sh path/to/resume.tex [options]

Examples:
  ./texpdf.sh base-tex/BASE-tex-resume.tex
  ./texpdf.sh Jobs/Rocket-Fall-2026/rocket-resume.tex --engine xelatex
  ./texpdf.sh Jobs/Rocket-Fall-2026/rocket-resume.tex --output Outputs/rocket-resume.pdf

Options:
  --engine, -Engine xelatex|lualatex
  --output, -Output path/to/output.pdf
  --passes, -Passes number
  --timeout, -Timeout seconds
  --keep-build-dir, -KeepBuildDir
EOF
}

die() {
  echo "$1" >&2
  exit "${2:-1}"
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine|-Engine)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      engine="$2"
      shift 2
      ;;
    --output|-Output)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      output_path="$2"
      shift 2
      ;;
    --passes|-Passes)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      passes="$2"
      shift 2
      ;;
    --timeout|-Timeout)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      timeout_seconds="$2"
      shift 2
      ;;
    --keep-build-dir|-KeepBuildDir)
      keep_build_dir=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      if [[ -z "$input_path" ]]; then
        input_path="$1"
        shift
      else
        die "Unexpected argument: $1"
      fi
      ;;
  esac
done

if [[ -z "$input_path" ]]; then
  print_usage
  exit 1
fi

case "$engine" in
  xelatex|lualatex) ;;
  *) die "--engine must be one of: xelatex, lualatex" ;;
esac

if ! [[ "$passes" =~ ^[0-9]+$ ]] || [[ "$passes" -lt 1 ]]; then
  die "--passes must be at least 1."
fi

if ! [[ "$timeout_seconds" =~ ^[0-9]+$ ]] || [[ "$timeout_seconds" -lt 30 ]]; then
  die "--timeout must be at least 30 seconds."
fi

resolve_existing_tex_file() {
  local path_value="$1"
  local resolved

  if ! resolved="$(cd -- "$(dirname -- "$path_value")" 2>/dev/null && pwd -P)/$(basename -- "$path_value")"; then
    die "Input file does not exist: $path_value"
  fi

  [[ -f "$resolved" ]] || die "Input path is not a file: $resolved"
  [[ "${resolved##*.}" == "tex" ]] || die "Input file must be a .tex file: $resolved"

  printf '%s\n' "$resolved"
}

to_unix_path_if_possible() {
  local path_value="$1"

  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$path_value" 2>/dev/null && return 0
  fi

  printf '%s\n' "$path_value"
}

get_engine_candidates() {
  local engine_name="$1"
  local home_dir="${HOME:-}"

  if command -v "$engine_name" >/dev/null 2>&1; then
    command -v "$engine_name"
  fi

  if [[ -n "${LOCALAPPDATA:-}" ]]; then
    to_unix_path_if_possible "$LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64/$engine_name.exe"
  fi

  if [[ -n "${ProgramFiles:-}" ]]; then
    to_unix_path_if_possible "$ProgramFiles/MiKTeX/miktex/bin/x64/$engine_name.exe"
  fi

  local program_files_x86
  program_files_x86="$(printenv 'ProgramFiles(x86)' 2>/dev/null || true)"
  if [[ -n "$program_files_x86" ]]; then
    to_unix_path_if_possible "$program_files_x86/MiKTeX/miktex/bin/x64/$engine_name.exe"
  fi

  case "$(uname -s 2>/dev/null || echo unknown)" in
    Darwin)
      printf '%s\n' \
        "/Library/TeX/texbin/$engine_name" \
        "/usr/local/bin/$engine_name" \
        "/opt/homebrew/bin/$engine_name" \
        "/opt/local/bin/$engine_name" \
        "/Applications/MiKTeX Console.app/Contents/bin/$engine_name"
      ;;
    Linux)
      printf '%s\n' \
        "/usr/local/bin/$engine_name" \
        "/usr/bin/$engine_name" \
        "/bin/$engine_name" \
        "/snap/bin/$engine_name" \
        "/opt/miktex/bin/$engine_name"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      if [[ -n "$home_dir" ]]; then
        printf '%s\n' \
          "$home_dir/.miktex/texmfs/install/miktex/bin/x64/$engine_name.exe" \
          "$home_dir/bin/$engine_name" \
          "$home_dir/.local/bin/$engine_name"
      fi
      ;;
  esac

  if [[ -n "$home_dir" ]]; then
    printf '%s\n' \
      "$home_dir/.miktex/texmfs/install/miktex/bin/x64/$engine_name" \
      "$home_dir/.miktex/texmfs/install/miktex/bin/x64/$engine_name.exe" \
      "$home_dir/bin/$engine_name" \
      "$home_dir/.local/bin/$engine_name"
  fi

  for search_root in /usr/local /opt /Applications "${home_dir:-}/.miktex" "${home_dir:-}/.local"; do
    [[ -n "$search_root" && -d "$search_root" ]] || continue
    find "$search_root" -maxdepth 6 -type f \( -name "$engine_name" -o -name "$engine_name.exe" \) 2>/dev/null | head -n 5
  done
}

find_latex_engine() {
  local engine_name="$1"
  local candidate

  while IFS= read -r candidate; do
    if [[ -n "$candidate" && -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(get_engine_candidates "$engine_name")

  return 1
}

show_missing_engine_message() {
  local engine_name="$1"

  echo "Could not find LaTeX engine: $engine_name"
  echo
  echo "The build has been stopped. Install MiKTeX, TeX Live, or another TeX distribution, then rerun the command."
  echo
  echo "Expected one of these engine executables:"
  get_engine_candidates "$engine_name" | while IFS= read -r candidate; do
    [[ -n "$candidate" ]] && echo "  $candidate"
  done
  echo
  echo "After installing a TeX distribution, verify with:"
  echo "  $engine_name --version"
}

get_log_tail() {
  local log_path="$1"
  local lines="${2:-40}"

  [[ -f "$log_path" ]] && tail -n "$lines" "$log_path"
}

get_missing_package_message() {
  local log_path="$1"
  local missing_file=""

  [[ -f "$log_path" ]] || return 1

  missing_file="$(
    sed -n -E \
      -e "s/^! LaTeX Error: File \`([^']+)' not found\./\1/p" \
      -e "s/^.*File \`([^']+\.sty)' not found\./\1/p" \
      -e "s/^.*LaTeX Error: File \`([^']+)' not found\./\1/p" \
      "$log_path" | head -n 1
  )"

  [[ -n "$missing_file" ]] || return 1

  local package_name="${missing_file##*/}"
  package_name="${package_name%.*}"

  cat <<EOF
Missing LaTeX package or file: $missing_file

The build has been stopped. Install the missing package, then rerun the command.

MiKTeX install command:
  miktex packages install $package_name
EOF
}

run_with_timeout() {
  local timeout_value="$1"
  shift

  "$@" &
  local command_pid=$!

  (
    sleep "$timeout_value"
    if kill -0 "$command_pid" >/dev/null 2>&1; then
      kill "$command_pid" >/dev/null 2>&1 || true
      sleep 2
      kill -9 "$command_pid" >/dev/null 2>&1 || true
    fi
  ) &
  local watcher_pid=$!

  wait "$command_pid"
  local exit_code=$?

  if kill -0 "$watcher_pid" >/dev/null 2>&1; then
    kill "$watcher_pid" >/dev/null 2>&1 || true
    wait "$watcher_pid" 2>/dev/null || true
  fi

  if [[ "$exit_code" -eq 143 || "$exit_code" -eq 137 ]]; then
    return 124
  fi

  return "$exit_code"
}

input_file="$(resolve_existing_tex_file "$input_path")"
input_directory="$(dirname -- "$input_file")"
input_name="$(basename -- "$input_file")"
input_stem="${input_name%.tex}"

if [[ -n "$output_path" ]]; then
  case "$output_path" in
    *.pdf) ;;
    *) die "Output path must end in .pdf: $output_path" ;;
  esac
  mkdir -p -- "$(dirname -- "$output_path")"
  output_file="$(cd -- "$(dirname -- "$output_path")" && pwd -P)/$(basename -- "$output_path")"
else
  mkdir -p -- "$script_dir/Outputs"
  output_file="$script_dir/Outputs/$input_stem.pdf"
fi

output_directory="$(dirname -- "$output_file")"
mkdir -p -- "$output_directory"

if [[ "$keep_build_dir" -eq 1 ]]; then
  build_dir="$output_directory/.$input_stem-build"
  delete_build_dir=0
else
  build_dir="$(mktemp -d "$output_directory/.$input_stem-build-XXXXXXXXXX")"
  delete_build_dir=1
fi

mkdir -p -- "$build_dir"

cleanup() {
  if [[ "${delete_build_dir:-0}" -eq 1 && -n "${build_dir:-}" && -d "$build_dir" ]]; then
    rm -rf -- "$build_dir"
  fi
}
trap cleanup EXIT

if ! engine_path="$(find_latex_engine "$engine")"; then
  show_missing_engine_message "$engine"
  exit 127
fi

engine_args=(
  "-interaction=nonstopmode"
  "-halt-on-error"
  "-file-line-error"
  "-output-directory=$build_dir"
  "$input_name"
)

engine_path_lower="$(printf '%s' "$engine_path" | tr '[:upper:]' '[:lower:]')"
if [[ "$engine_path_lower" == *miktex* ]]; then
  engine_args=("-enable-installer" "${engine_args[@]}")
fi

for ((pass = 1; pass <= passes; pass++)); do
  echo "Running LaTeX pass $pass/$passes..."

  run_with_timeout "$timeout_seconds" bash -c '
    workdir="$1"
    shift
    cd -- "$workdir"
    exec "$@"
  ' bash "$input_directory" "$engine_path" "${engine_args[@]}"
  exit_code=$?

  if [[ "$exit_code" -eq 124 ]]; then
    echo "LaTeX timed out after $timeout_seconds seconds. The build process was stopped."
    echo "If MiKTeX was installing packages, rerun the command after installation finishes."
    exit 124
  fi

  if [[ "$exit_code" -ne 0 ]]; then
    log_path="$build_dir/$input_stem.log"
    if missing_package_message="$(get_missing_package_message "$log_path")"; then
      echo "$missing_package_message"
      exit "$exit_code"
    fi

    echo "LaTeX failed with exit code $exit_code. Log: $log_path"
    get_log_tail "$log_path" 40
    exit "$exit_code"
  fi
done

generated_pdf="$build_dir/$input_stem.pdf"
if [[ ! -f "$generated_pdf" ]]; then
  die "LaTeX finished but did not create the expected PDF: $generated_pdf"
fi

cp -f -- "$generated_pdf" "$output_file"
echo "Wrote $output_file"
