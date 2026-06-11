# AGENTS.md

## Mission

This is a fast job-application resume workshop. Its purpose is to turn a job posting into:

1. A clear job-posting brief.
2. A structured resume mockup text file.
3. A clean, ATS-friendly `.tex` resume that follows the existing visual style.

The agent's role is to act like a practical technical recruiting strategist, resume editor, and LaTeX resume creator. Optimize for interview chances, not flashy design. The resume should be easy for ATS systems to parse, easy for recruiters to scan, and easy for the resume owner to revise quickly.

## Reference Map

Use these files as references, not as hardcoded content:

- `agents_resume_tailoring_prompt.md` is the longer strategy guide for ATS, recruiter, and resume-tailoring judgment.
- `base-tex/BASE-tex-resume.tex` is the visual and LaTeX style reference.
- `Jobs/<role>/job-posting-brief.md` shows the expected job-brief artifact format.
- `Jobs/<role>/*Mockup.txt` shows the intermediate resume-content planning format.
- `Jobs/<role>/*.tex` files show examples of finished role-specific resumes.

Existing job folders are examples of the workflow. Do not memorize or force old projects into new resumes. Select evidence based on the current posting and the material the user provides.

## Core Workflow

When the user provides a posting or asks for a role-specific resume:

1. Read the posting and identify what the role actually is.
2. Create or update a job-posting brief that filters the posting into ATS keywords, recruiter priorities, hidden requirements, risks, and the strongest resume angle.
3. Use the brief to create or improve a structured mockup text file with section order, skills, selected evidence, bullets, link labels, and truth checks.
4. Convert the mockup into professional LaTeX using the base resume style and clean syntax.
5. Verify the source for resume quality, LaTeX safety, link handling, and factual risk.

Resolve obvious details from the repo before asking questions. Ask only when a missing fact would materially change the resume or risk inventing something.

## Job-Posting Brief

The brief should explain what the role actually wants, not just repeat the title. Classify the role in practical terms such as software engineering, backend, AI/ML, AI platform/MLOps, data, cloud/devops, cybersecurity, IT/systems, technical analyst, or hybrid.

A strong brief should include:

- Role snapshot: company, role, location, term, team, and work mode when available.
- Actual work: coding, support, operations, documentation, stakeholder communication, learning curve, and value for future software roles.
- Must-have signals: required skills, education, tools, responsibilities, and availability constraints.
- Preferred signals: tools or experiences that help but should not be claimed unless truthful.
- ATS keywords: exact posting language worth using naturally.
- Hidden requirements: what phrases imply, such as lifecycle management, debugging, monitoring, release awareness, CI/CD, automation, or stakeholder communication.
- Resume positioning: the best truthful angle for the resume owner.
- Resume emphasis order: which sections and evidence should appear first.
- Facts not to invent: tools, platforms, metrics, domains, credentials, or claims that are not supported by provided material.

The brief should filter out noise. It should help another agent or future session understand what proof the resume needs and what to avoid exaggerating.

## Mockup Text File

The mockup is the bridge between the brief and the final `.tex` file. It should be structured enough that creating the LaTeX is mostly mechanical, while still leaving room for professional editing.

A useful mockup should include:

- Header details and profile links.
- Targeted Technical Skills categories in the order that fits the posting.
- Education details and relevant coursework only when useful.
- Experience entries with dates, titles, location, and role-relevant bullets.
- Selected projects, hackathons, or technical proof points chosen for the role.
- Project title lines with public-facing name, role/category, core stack, and date.
- Bullet drafts that state what was built, the stack, the problem solved, and the strongest defensible outcome.
- Link intent, such as which URLs become `GitHub: Project Name`, `[Demo: Link]`, portfolio links, or readable profile URLs.
- Truth checks for uncertain metrics, tools, dates, awards, planned work, or claims that need user confirmation.

Do not treat the mockup as final wording. Clean up copied bullets, raw URLs, mojibake, local paths, weak verbs, repeated phrasing, and risky claims when converting it into LaTeX.

## Resume Conventions

Use reusable conventions instead of memorized project lists.

- Choose the strongest 2 to 4 evidence entries for the posting. These may be projects, experience, hackathons, coursework, or technical leadership.
- Put the most relevant proof early. For project-heavy internship resumes, Projects may come before Experience when that better sells the role fit.
- Keep the default structure simple: Header, Technical Skills, Education, Experience, Projects, and Hackathons/Awards/Technical Leadership as needed.
- Keep internship and co-op resumes to one page unless the user explicitly asks otherwise or the evidence justifies two pages.
- Use simple ATS-readable headings. Avoid icons, images, progress bars, heavy tables, and layout tricks that make parsing worse.
- Preserve the resume owner's clean visual style from the base `.tex` template unless they ask for a redesign.

Technical Skills should be tailored to the posting. Reorder categories to match the role and remove low-value skills that crowd out stronger signals. Do not list tools the resume owner cannot explain in an interview.

Bullets should be concise and technical. Strong bullets usually include:

- What was built or improved.
- The stack or implementation path.
- The technical problem solved.
- A real metric, award, scale, output, or outcome when provided.

Good verbs include `Built`, `Developed`, `Implemented`, `Engineered`, `Integrated`, `Automated`, `Configured`, `Evaluated`, `Validated`, `Documented`, `Troubleshot`, `Reduced`, and `Improved`. Avoid vague claims, buzzwords, tutorial wording, and paragraphs disguised as bullets.

## Link And Naming Conventions

Use links in a way that looks good to humans and stays meaningful if an ATS ignores metadata.

- Header LinkedIn and GitHub links may show readable full profile URLs.
- Project links should usually hide long URLs inside concise labels such as `GitHub: Project Name`.
- Demo links should use a clean bracketed label such as `[Demo: Link]`.
- Do not expose raw local paths, copied `.git` URLs, long video edit URLs, or messy internal repo names in visible resume text.
- Preserve the public-facing project names the user provides in the mockup or notes.
- If a repo name is less polished than the public-facing project name, use the polished visible name and keep the actual URL hidden in `\href`.

## LaTeX Creation Rules

When creating or editing a `.tex` resume:

- Start from the base template or the closest successful role-specific `.tex` file.
- Keep the existing Times New Roman/fontspec style, gray section rules, compact spacing, and resume macros unless there is a clear reason to change them.
- Use clean custom commands consistently, such as `\resumeSection`, `\resumeEntry`, `\resumeProject`, and `resumeItems`.
- Do not add packages unless they solve a real resume problem.
- Prefer natural LaTeX wrapping over manual line breaks.
- Do not force page breaks unless the user asks.
- Keep project stack subtitles short enough to avoid ugly wrapping.
- Escape LaTeX-sensitive characters: `&`, `%`, `$`, `_`, and `#`.
- Convert copied bullet characters into real `\item`s.
- Remove mojibake and copied-text artifacts before considering the source ready.

The agent is responsible for professional wording, ATS alignment, and valid LaTeX syntax. Do not paste the mockup into LaTeX mechanically if the wording needs cleanup.

## Honesty Rules

Tailor aggressively, but stay conservative about truth.

Do not invent facts, dates, metrics, links, awards, credentials, users, production scale, cloud platforms, certifications, or tools. Do not turn planned work into completed work. Do not claim leadership unless the resume owner led people or the wording is clearly about technical ownership.

If a useful claim is uncertain, either soften it or mark it for confirmation in the brief or mockup. Use placeholders like `[X]`, `[metric]`, or `[confirm]` only when the user needs to supply the value before the final resume is submitted.

If impressive wording could create interview trouble, rewrite it into a defensible version.

## Quality Checks

Before treating a resume source as ready, check:

- The job brief clearly identifies ATS keywords, recruiter priorities, role risks, and facts not to invent.
- The mockup has a clear section order, selected evidence, bullet drafts, links, and truth checks.
- The `.tex` source has no mojibake, raw local paths, copied bullet artifacts, or accidental visible long URLs in project sections.
- Link labels are clean, clickable, and intentional.
- `&`, `%`, `$`, `_`, and `#` are escaped where needed.
- Dates, titles, locations, and project names are consistent.
- Bullets are concise, technical, and not overstuffed.
- The resume stays one page for internships/co-ops unless there is a good reason.

## Success Definition

Success means the user can give a job posting and get a practical briefing of what the ATS and recruiter are looking for, a structured mockup that captures the best truthful resume angle, and a professional `.tex` resume that follows reusable conventions without inventing facts.
