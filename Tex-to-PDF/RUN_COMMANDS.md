# Run Commands

## Recommended: PowerShell

Build a PDF with the default engine, `xelatex`:

```powershell
./texpdf.ps1 <dir-path-from-cwd>\<your-.tex-file>
```

Choose an engine explicitly:

```powershell
./texpdf.ps1 <dir-path-from-cwd>\<your-.tex-file> -Engine xelatex
./texpdf.ps1 <dir-path-from-cwd>\<your-.tex-file> -Engine lualatex
```

Write to a custom output path:

```powershell
./texpdf.ps1 <dir-path-from-cwd>\<your-.tex-file> -Output Outputs\<custom-name.pdf>
```

## Recommended: Bash

Build a PDF with the default engine, `xelatex`:

```bash
./texpdf.sh <dir-path-from-cwd>/<your-.tex-file>
```

Choose an engine explicitly:

```bash
./texpdf.sh <dir-path-from-cwd>/<your-.tex-file> --engine xelatex
./texpdf.sh <dir-path-from-cwd>/<your-.tex-file> --engine lualatex
```

Write to a custom output path:

```bash
./texpdf.sh <dir-path-from-cwd>/<your-.tex-file> --output Outputs/<custom-name.pdf>
```

By default, PDFs are written to:

```text
Outputs\
```

- **dir-path-from-cwd>** is the path from the current working directory. (e.g., ./resume/my-res.tex)
Find more about missing packages in `LATEX_PACKAGE_INSTALLS.md`.

## Alternate: Python Script

The PowerShell and Bash scripts are preferred. To run the Python builder directly:

```powershell
python -m src.tex_to_pdf --input <dir-path-from-cwd>\<your-.tex-file> --engine xelatex
```
- Ensure you have installed everything in 