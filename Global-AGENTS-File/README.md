# Agent Guidance

Contains two versions of a global coding-agent behavior guide. The guide is meant to reduce common LLM coding mistakes without turning the agent into a rigid process machine.

The original version was inspired by practical coding-agent guidance from [Andrej Karpathy](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md) and similar discussions about where LLMs tend to fail: overengineering, touching unrelated code, guessing intent, and skipping verification.

## Files

- `AGENTS-MD-GLOBAL-ORIG.md` is the original version.
- `GLOBAL-AGENTS.md` is the newer refined version.

## Philosophy

The revision is intentionally conservative. The goal was not to redesign the guide or add a large rulebook.

The goal was to preserve the original philosophy: think before coding, keep solutions simple, make surgical edits, match the existing codebase, and verify work in a practical way.

Preserving simplicity was more important than adding new rules.

## Key Improvements

- Reduces unnecessary clarification questions by encouraging the agent to use available context first.
- Keeps the bias toward simple solutions and avoiding speculative abstractions.
- Reinforces surgical edits without implying every changed line must be explicitly named by the user.
- Makes testing guidance more realistic: run relevant existing tests, add tests when risk justifies it, and use lightweight checks for tiny changes.
- Improves agent autonomy while still asking for clarification when genuinely blocked.
- Adds lightweight safety boundaries around secrets, environment variables, destructive actions, production changes, and git operations.
- Keeps the document short and context-efficient.

## Notes

This configuration is not meant to be perfect or universal. It is a small refinement of the original guidance, aimed at making coding agents a little more practical in real-world repositories while keeping the same direct style. 
