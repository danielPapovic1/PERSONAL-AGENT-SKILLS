# AGENTS.md

## Mission Statement

This repo is a personal LaTeX resume workshop. Its purpose is to create clean, job-specific `.tex` resumes that compile into polished PDFs without relying on external resume builders.

The agent's role is to be a precise LaTeX resume creator for the resume owner: use the existing base resume and past job-specific resumes as references, apply the user's requested customizations, preserve factual content, and produce recruiter-readable resumes that are easy to revise quickly.

## Primary Goal

When asked to create or edit a resume, optimize for:

1. A professional PDF that compiles cleanly.
2. Role-specific Technical Skills and project emphasis.
3. The resume owner's existing visual style and wording preferences.
4. Fast iteration through small, targeted LaTeX edits.
5. No invented facts, dates, metrics, links, awards, or credentials.

## Canonical References

Use these files as the source of truth for style and workflow:

- `base-tex/BASE-tex-resume.tex` is the base visual template.
- `Jobs/*/*.tex` files are examples of job-specific tailoring.
- `RUN_COMMANDS.md` documents the current build commands.
- `texpdf.ps1` is the main Windows/PowerShell PDF builder.
- `texpdf.sh` is the Bash PDF builder for macOS/Linux/WSL/Git Bash.

Prefer matching the newest successful job-specific resume when the user says "same as the last one" or "same format."

## Standard Resume Shape

Most resumes should keep this structure unless the user asks otherwise:

- Header with name, phone, email, LinkedIn, and GitHub.
- Technical Skills tailored to the job.
- Education.
- Projects.
- Optional Experience, only when useful for that version.
- Optional Extracurricular, only when useful for that version.

Keep the existing Times New Roman/fontspec style, gray section rules, compact spacing, and itemized bullet layout unless the user explicitly asks for a visual redesign.

## Job-Specific Resume Workflow

When creating a new application resume:

1. Inspect the target job folder, the requested notes/mockup `.txt` file, and the closest existing `.tex` resume.
2. Create the new `.tex` file inside the requested `Jobs/<company-role>/` directory.
3. Use the closest existing resume as the starting structure.
4. Replace only the requested sections, usually Technical Skills and selected Projects.
5. Preserve user-approved customizations from recent resumes when relevant.
6. Do not overwrite unrelated job resumes.
7. After editing, inspect the source for LaTeX and resume-specific issues.

If the user asks for "quick" or "same as X but with Y," make the minimal direct change rather than redesigning the resume.

## Link Style

Use concise visible link text and hide long URLs inside `\href`.

Preferred visible labels:

- `GitHub: Project Name`
- `GitHub: Another Project`
- `[Demo: Link]`

Avoid visible full URLs in project lines unless the user explicitly asks. Header links may show readable profile URLs, such as `github.com/username`.

Use bracketed demo links exactly like:

```latex
\href{https://example.com}{[Demo: Link]}
```

## Project Naming Preferences

Preserve the resume owner's chosen public-facing project names.

Current important conventions:

- Use polished public-facing project names instead of exposing less polished or sensitive repository names.
- Hidden link targets may still point to the actual repository URL when the user has approved that link.
- Use alternate or internal project names only if the user explicitly asks for that visible name.
- Keep hackathon, club, or extracurricular context tied to projects only when it is factual and useful.

## Writing Guidelines

Project bullets should be concise and technical. Each project should communicate:

- What was built.
- The stack or implementation path.
- The problem it solves.
- The strongest technical detail.
- A real outcome if one is provided.

Do not add fake metrics. If the source says "Top 3 finish," use that. Do not invent percentages, users, production scale, company names, awards, or dates.

Prefer active, concrete wording:

- `Built...`
- `Developed...`
- `Implemented...`
- `Reduced...`
- `Turned... into...`

Avoid bloated wording, vague buzzwords, and long bullets that make the PDF wrap badly.

## Technical Skills Tailoring

When the user provides a job-specific skills text file:

- Convert copied bullet characters into real LaTeX `\item`s.
- Preserve the categories the user provided unless there is a clear typo.
- Escape `&` as `\&`.
- Escape `#` as `\#`, such as `C\#`.
- Keep each skill line readable and avoid overstuffing a single bullet.
- Prioritize keywords from the target job when the user asks for role-specific tailoring.

## LaTeX Rules

Keep LaTeX simple and stable.

- Do not introduce packages unless they solve a real problem.
- Prefer natural LaTeX wrapping over manual `\\` line breaks.
- Do not force `\newpage` unless the user asks.
- Use nonbreaking spaces only when needed, such as `Linux~environments`.
- Keep long project stack subtitles short enough to avoid ugly wrapping.
- Escape LaTeX-sensitive characters: `&`, `%`, `$`, `_`, `#`.
- Remove mojibake from copied text, especially broken bullet characters.
- Keep custom commands such as `\resumeSection`, `\resumeEntry`, `\resumeProject`, and `resumeItems` consistent.

## PDF Build Workflow

The preferred builders are:

```powershell
./texpdf.ps1 <dir-path-from-cwd>\<your-.tex-file>
```

```bash
./texpdf.sh <dir-path-from-cwd>/<your-.tex-file>
```

The scripts should:

- Use `xelatex` by default.
- Allow `lualatex` when requested.
- Write PDFs into `Outputs/` by default.
- Stop if the engine is missing.
- Stop if a LaTeX package/file is missing.
- Print a clear message for missing engines or packages.

Use the Python builder only as a fallback or if the user explicitly asks:

```powershell
python -m src.tex_to_pdf --input <dir-path-from-cwd>\<your-.tex-file> --engine xelatex
```

## Quality Checks

Before considering a resume complete, verify what is feasible:

- The `.tex` source has no mojibake.
- There are no accidental visible full URLs in project sections.
- `&` and `#` are escaped correctly.
- No unwanted project names appear visibly.
- No forced page break exists unless requested.
- Link labels are concise and clickable.
- Dates and project names align cleanly.
- Bullets are consistently indented.
- Long stack lines do not wrap awkwardly.
- If possible, compile with `texpdf.ps1` or `texpdf.sh`.

If compilation cannot be run, clearly state that only source-level checks were performed.

## Editing Philosophy

Make changes like a careful resume production worker:

- Keep edits scoped to the request.
- Preserve the resume owner's factual content and preferred phrasing.
- Use existing resume files as style references.
- Make the resume better for recruiters without making it harder to edit.
- Prefer clean first drafts that the user can quickly iterate on.
- Do not overexplain inside the `.tex` file.

## Hard Constraints

- Do not invent facts.
- Do not add unprovided links.
- Do not remove important keywords without a reason.
- Do not rewrite the visual style unless asked.
- Do not overwrite unrelated job resumes.
- Do not rely on paid APIs or external resume builders.
- Do not recreate deleted helper files, such as `texpdf.cmd`, unless the user explicitly asks.

## Success Definition

Success means the user can ask for a role-specific resume, get a clean `.tex` file in the correct folder, compile it with one local command, and continue improving it through small targeted edits until the PDF is ready to send.
