# Local LaTeX Resume PDF Builder

This project exists so you do not have to rely on resume websites that show ads, lock exports behind accounts, or charge fees to generate a PDF.

With this tool, you keep your resume source locally as a `.tex` file and compile it into a professional PDF on your own machine at no cost.

## What It Does

The converter takes a single LaTeX resume file:

```powershell
.\texpdf.ps1 path\to\resume.tex -Engine xelatex
```

and produces a PDF in:

```text
Outputs\
```

The `<path-to>texpdf.ps1` command is a small local PowerShell builder. It does not render LaTeX itself. It calls a local TeX engine such as `xelatex` or `lualatex`, then copies the generated PDF into `Outputs\`.

## Why Use This

- No paid resume builder.
- No ads.
- No upload required.
- No account required.
- Full control over your resume source.
- Repeatable PDF generation from any `.tex` resume file.

## Current Setup

This repo is currently set up for Windows with MiKTeX.

MiKTeX provides the actual LaTeX engines:

```text
xelatex
lualatex
```

The PowerShell command finds those engines and runs them against the `.tex` file you provide.

## Requirements

This repo includes a `requirements.txt` file.

If you use the Python builder, install the Python packages from it:

```powershell
pip install -r requirements.txt
```

For the default Windows setup, you also need MiKTeX because it provides `xelatex` and `lualatex`.

Download MiKTeX here:

```text
https://miktex.org/download
```

## macOS and Linux

On macOS or Linux, install a TeX engine for that OS first.

Common choices:

```text
macOS: MacTeX, BasicTeX, or MiKTeX
Linux: TeX Live or MiKTeX
```

If `xelatex` or `lualatex` is available on `PATH`, the script should work with little or no change.

If the engine is installed somewhere custom, update the engine lookup paths in `texpdf.ps1`.

You can also use MiKTeX on macOS or Linux if you want a similar setup across operating systems.

## Python Version

The PowerShell and Bash scripts are the preferred builders, but you can run the Python version in `src` directly if you want:

```powershell
python -m src.tex_to_pdf --input path\to\resume.tex --engine xelatex
```

By default, it writes the PDF to:

```text
Outputs\
```

You can choose a custom output path:

```powershell
python -m src.tex_to_pdf --input path\to\resume.tex --output Outputs\resume.pdf
```

Useful options:

```text
--engine xelatex|lualatex
```

## Where To Learn More

For package installs and missing `.sty` errors:

```text
LATEX_PACKAGE_INSTALLS.md
```

For how the MiKTeX PDF builder works:

```text
PDF-BUILDER.md
```

For common commands:

```text
RUN_COMMANDS.md
```

## References

- Setup requirements: `requirements.txt`
- Agent instructions example: `AGENTS.EXAMPLE.md`

`AGENTS.EXAMPLE.md` is an example root instruction file for your agent to use when helping make your `.tex` resume. I recommend customizing it for your own workflow, keeping your `.tex` files in a specific folder, and pre-making the `Outputs/` directory for a cleaner experience.

To use the included `tex-pdf` skill in another local project, keep the exact skill folder structure when copying it. You can copy `.agents/skills/tex-pdf/` into the same path in that project, or copy the `tex-pdf` folder into your global `skills/` folder.
