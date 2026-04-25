# AGENT.md

## Purpose

This document defines how AI agents should interact with the PVM codebase.

## Rules

- Always prefer POSIX-compliant shell.
- Do not introduce unnecessary dependencies.
- Keep functions small and composable.
- Maintain readability over cleverness.

## Behavior

Agents must:
- Follow project structure
- Respect existing coding style
- Avoid breaking backward compatibility
- Write clear commit messages

## Output Expectations

- Provide full file content when generating code
- Include explanations for complex logic
