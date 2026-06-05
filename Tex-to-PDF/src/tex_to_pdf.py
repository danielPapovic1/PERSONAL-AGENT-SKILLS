from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Optional

import typer
from PyPDF2 import PdfReader
from rich.console import Console


app = typer.Typer(add_completion=False, help="Compile one .tex file into a PDF.")
console = Console()

ENGINES = ("xelatex", "lualatex")
DEFAULT_OUTPUT_DIR = "Outputs"


class CompileError(RuntimeError):
    pass


def resolve_input(input_path: Path) -> Path:
    resolved = input_path.expanduser().resolve()

    if not resolved.exists():
        raise typer.BadParameter(f"Input file does not exist: {resolved}")

    if not resolved.is_file():
        raise typer.BadParameter(f"Input path is not a file: {resolved}")

    if resolved.suffix.lower() != ".tex":
        raise typer.BadParameter(f"Input file must be a .tex file: {resolved}")

    return resolved


def resolve_output(input_path: Path, output_path: Optional[Path]) -> Path:
    if output_path is None:
        return Path.cwd() / DEFAULT_OUTPUT_DIR / f"{input_path.stem}.pdf"

    resolved = output_path.expanduser().resolve()
    if resolved.suffix.lower() != ".pdf":
        raise typer.BadParameter(f"Output path must end in .pdf: {resolved}")

    return resolved



def find_engine(requested_engine: Optional[str]) -> str:
    if requested_engine:
        engine_path = shutil.which(requested_engine)
        if engine_path:
            return engine_path
        raise typer.BadParameter(
            f"Requested LaTeX engine was not found on PATH: {requested_engine}"
        )

    for engine in ENGINES:
        engine_path = shutil.which(engine)
        if engine_path:
            return engine_path

    raise typer.BadParameter(
        "No LaTeX engine found on PATH. Install MiKTeX, MacTeX, TeX Live, or "
        "another TeX distribution, then make sure xelatex or lualatex can be "
        "run from this terminal."
    )


def tail(text: str, max_lines: int = 40) -> str:
    return "\n".join(text.splitlines()[-max_lines:])


def is_miktex_engine(engine_path: str) -> bool:
    return "miktex" in engine_path.lower()


def run_latex(
    input_path: Path,
    output_path: Path,
    engine_path: str,
    passes: int,
    keep_build_dir: bool,
    timeout_seconds: int,
) -> Path:
    if passes < 1:
        raise typer.BadParameter("--passes must be at least 1.")
    if timeout_seconds < 30:
        raise typer.BadParameter("--timeout must be at least 30 seconds.")

    output_path.parent.mkdir(parents=True, exist_ok=True)

    if keep_build_dir:
        build_dir = output_path.parent / f".{input_path.stem}-build"
        build_dir.mkdir(parents=True, exist_ok=True)
        cleanup = None
    else:
        cleanup = tempfile.TemporaryDirectory(
            prefix=f".{input_path.stem}-build-",
            dir=output_path.parent,
            ignore_cleanup_errors=True,
        )
        build_dir = Path(cleanup.name)

    try:
        command = [
            engine_path,
            "-interaction=nonstopmode",
            "-halt-on-error",
            "-file-line-error",
            f"-output-directory={build_dir}",
            input_path.name,
        ]
        if is_miktex_engine(engine_path):
            command.insert(1, "-enable-installer")

        for pass_number in range(1, passes + 1):
            console.print(f"Running LaTeX pass {pass_number}/{passes}...")
            try:
                result = subprocess.run(
                    command,
                    cwd=input_path.parent,
                    capture_output=True,
                    text=True,
                    check=False,
                    timeout=timeout_seconds,
                )
            except subprocess.TimeoutExpired as exc:
                raise CompileError(
                    f"LaTeX timed out after {timeout_seconds} seconds.\n"
                    f"Command: {' '.join(command)}\n"
                    "If MiKTeX is installing missing packages, rerun the command "
                    "or install the missing packages from MiKTeX Console."
                ) from exc

            if result.returncode != 0:
                log_path = build_dir / f"{input_path.stem}.log"
                details = [
                    f"LaTeX failed with exit code {result.returncode}.",
                    f"Command: {' '.join(command)}",
                ]
                if result.stdout:
                    details.append(f"stdout tail:\n{tail(result.stdout)}")
                if result.stderr:
                    details.append(f"stderr tail:\n{tail(result.stderr)}")
                if log_path.exists():
                    details.append(f"Full log: {log_path}")
                raise CompileError("\n\n".join(details))

        generated_pdf = build_dir / f"{input_path.stem}.pdf"
        if not generated_pdf.exists():
            raise CompileError(
                f"LaTeX finished but did not create the expected PDF: {generated_pdf}"
            )

        shutil.copy2(generated_pdf, output_path)
        return output_path
    finally:
        if cleanup is not None:
            cleanup.cleanup()


def validate_pdf(pdf_path: Path) -> int:
    reader = PdfReader(str(pdf_path))
    return len(reader.pages)


@app.command()
def main(
    input_path: Path = typer.Option(
        ...,
        "--input",
        "-i",
        help="Path to the .tex file, relative to the current working directory or absolute.",
    ),
    output_path: Optional[Path] = typer.Option(
        None,
        "--output",
        "-o",
        help="Optional output PDF path. Defaults to writing into Outputs/.",
    ),
    engine: Optional[str] = typer.Option(
        None,
        "--engine",
        help="Optional LaTeX engine: xelatex or lualatex.",
    ),
    passes: int = typer.Option(
        2,
        "--passes",
        help="Number of LaTeX passes to run.",
    ),
    keep_build_dir: bool = typer.Option(
        False,
        "--keep-build-dir",
        help="Keep generated aux/log files in a build directory next to the PDF.",
    ),
    timeout_seconds: int = typer.Option(
        180,
        "--timeout",
        help="Maximum seconds to allow each LaTeX pass to run.",
    ),
) -> None:
    if engine is not None and engine not in ENGINES:
        raise typer.BadParameter(f"--engine must be one of: {', '.join(ENGINES)}")

    resolved_input = resolve_input(input_path)
    resolved_output = resolve_output(resolved_input, output_path)
    engine_path = find_engine(engine)

    try:
        pdf_path = run_latex(
            input_path=resolved_input,
            output_path=resolved_output,
            engine_path=engine_path,
            passes=passes,
            keep_build_dir=keep_build_dir,
            timeout_seconds=timeout_seconds,
        )
        page_count = validate_pdf(pdf_path)
    except CompileError as exc:
        console.print(f"[red]{exc}[/red]")
        raise typer.Exit(code=1) from exc

    console.print(f"[green]Wrote {pdf_path} ({page_count} page(s)).[/green]")


if __name__ == "__main__":
    app()
