# Installing LaTeX Packages

MiKTeX provides the LaTeX engines, such as `xelatex` and `lualatex`, but each `.tex` file may also need LaTeX packages.

Packages are loaded in `.tex` files with commands like:

```latex
\usepackage{geometry}
\usepackage{enumitem}
\usepackage{hyperref}
\usepackage{xcolor}
```

If a package is missing, compilation may fail with an error like:

```text
LaTeX Error: File `geometry.sty' not found.
```

## Install Packages With MiKTeX

Use this command pattern:

```powershell
mpm --install=PACKAGE_NAME
```

Examples from this project:

```powershell
mpm --install=geometry
```

```powershell
mpm --install=enumitem
```

```powershell
mpm --install=uniquecounter
```

If MiKTeX cannot find package names, refresh the package database:

```powershell
& "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\miktex.exe" packages update-package-database

- If not on Windows location of the executable will be different. 
```

**(These are examples. The packages you need to install depend on how your .tex file was made.)**

## Engine Compatibility

Some packages only work with certain engines.

For example:

```latex
\usepackage{fontspec}
```

requires `xelatex` or `lualatex`. It will not work correctly with `pdflatex`.

For this project, prefer:

```powershell
python src\tex_to_pdf.py --input path\to\resume.tex --engine xelatex
```

or:

```powershell
python src\tex_to_pdf.py --input path\to\resume.tex --engine lualatex
```

If conversion fails, check the error for a missing `.sty` file, install the related MiKTeX package, then run the converter again.