# Example: Tier 1 Review Output

> This is an annotated example of what a Tier 1 (Foundations) harness review looks like. Use this as a reference for the expected depth, format, and quality of a Tier 1 review. Tier 1 reviews are compact (~1 page) with 5 core scores and 3 focused improvements.

> **Project:** taskr (Python CLI task management tool, solo developer side project)
> **Tier detected:** Tier 1 (sparse CLAUDE.md, no skills/prompts, no validation, no hooks, solo contributor)

---

# Harness Engineering Review: taskr

**Date:** 2026-03-10
**Maturity Level:** Level 1 — Foundations
**Overall Score:** 1.5/5

---

## Maturity Scorecard

| Dimension | Score | Evidence |
|-----------|-------|----------|
| Context Engineering | 2/5 | `CLAUDE.md` exists (12 lines) with project description but missing directory structure, commands, and conventions sections |
| Architectural Constraints | 1/5 | No output format specs. `pyproject.toml` has a ruff config but no agent-output validation |
| Entropy Management | 1/5 | No consistency checks. `CLAUDE.md` references a `docs/` directory that does not exist |
| Verification & Feedback | 2/5 | Human reviews output manually before use. No structured feedback capture. `tests/test_tasks.py` has 3 unit tests but no coverage config |
| Agent Ergonomics | 2/5 | `src/` has some decomposition (cli.py, tasks.py, storage.py) but no pipeline structure, no skills, no slash commands |
| Operational Monitoring | 1/5 | No logging or quality tracking of task output. Output is consumed directly with no observability. |

---

## What's Working Well

1. **CLAUDE.md exists and is accurate** — The project description correctly states what taskr does. This is a better starting point than most solo projects.

2. **Basic test coverage** — `tests/test_tasks.py` has 3 passing tests covering task creation, completion, and listing. Not comprehensive, but the testing habit is there.

---

## Top 3 Improvements

### 1. Expand CLAUDE.md to cover the four essentials (Context Engineering)

**Current:** CLAUDE.md has a project description only (12 lines).
**Target:** Add directory structure, commands (`python -m taskr`, `pytest`), and conventions (file naming, error handling patterns).
**Why it matters:** Without these sections, an AI agent has to guess your project structure and figure out how to run things. That guessing produces unreliable output.
**First step:** Add a "## Directory Structure" section listing your `src/`, `tests/`, and config files with one-line descriptions.
**Effort:** quick-win

### 2. Add an output format spec for task export (Architectural Constraints)

**Current:** `taskr export` produces JSON but the schema is not documented anywhere. The format could change between runs.
**Target:** Create a `TASK-SPEC.md` defining the required JSON fields, types, and validation rules.
**Why it matters:** Without a spec, any tool consuming your export (including AI agents) can break silently when the format drifts.
**First step:** Run `taskr export`, copy the output, document each field in a `TASK-SPEC.md` file.
**Effort:** quick-win

### 3. Fix the broken docs reference (Entropy Management)

**Current:** CLAUDE.md references `docs/architecture.md` but no `docs/` directory exists.
**Target:** Either create the docs directory with the referenced file, or remove the reference.
**Why it matters:** Broken references erode trust in your documentation. An AI agent following this reference will waste a tool call and may hallucinate content.
**First step:** Delete the broken reference from CLAUDE.md. Add docs later if needed.
**Effort:** quick-win

---

## What to Focus on to Reach Tier 2

1. Complete the CLAUDE.md four essentials (overview, structure, commands, conventions)
2. Add at least one validation script that checks output format
3. Create your first skill prompt for a repeatable task (e.g., a code review checklist)
4. Set up a pre-commit hook running your linter
5. Add a feedback template for tracking what works and what doesn't
