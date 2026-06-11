---
name: tex-pdf
description: Build a LaTeX .tex file into a PDF using this skill's local Scripts/texpdf.ps1 or Scripts/texpdf.sh helper. Use when the user asks to compile, build, render, or convert a TeX/LaTeX resume or document to PDF. 
---

# TeX to PDF

Use this skill to turn a `.tex` file into a PDF with the helper scripts bundled in this skill.

## Workflow

1. Identify the `.tex` file the user wants to compile.
2. Prefer the script for the current operating system:
   - Windows / PowerShell: `Scripts/texpdf.ps1`
   - macOS / Linux / Bash: `Scripts/texpdf.sh`
3. Run the script from the repository or workspace where the `.tex` path is valid.
4. Inspect the command output for missing engines, missing packages, LaTeX errors, and the generated PDF path.
5. Report the PDF path when compilation succeeds. If compilation fails, report the relevant error and the next concrete fix.

## Commands

On Windows:

```powershell
.\.agents\skills\tex-pdf\Scripts\texpdf.ps1 path\to\file.tex
```

On macOS or Linux:

```bash
./.agents/skills/tex-pdf/Scripts/texpdf.sh path/to/file.tex
```

Write to a custom output path:

```powershell/bash
./.agents/skills/tex-pdf/Scripts/texpdf.sh||ps1 <dir-path-from-cwd>/<your-.tex-file> --output Outputs/<custom-name.pdf>
```

## Notes

- Use `xelatex` by default unless the user requests a different engine or the script chooses one explicitly.
- Do not edit the `.tex` file unless the user asked for content changes or a build error requires a source fix.
- Do not invent missing packages, links, dates, or resume facts. Surface build errors directly.
- Keep changes scoped to compilation and practical verification.
- If build fails tell user why.
