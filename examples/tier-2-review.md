# Example: Tier 2 Review Output

> This is an annotated example of what a Tier 2 (Team-ready) harness review looks like. Use this as a reference for the expected depth, format, and quality of a Tier 2 review.

> **Project:** bv-workdesk (unified productivity system with coaching pipeline, content system, task management)
> **Tier detected:** Tier 2 (comprehensive CLAUDE.md, validation scripts, 12+ skills with some rubrics/examples, feedback templates exist but loop not closed)

---

# Harness Engineering Review: bv-workdesk

**Date:** 2026-03-10
**Maturity Level:** Level 2 (bordering Level 3) — Team-ready
**Overall Score:** 3.6/5

---

## Maturity Scorecard

| Dimension | Score | Key Strength | Key Gap |
|-----------|-------|-------------|---------|
| Context Engineering | 4/5 | Comprehensive CLAUDE.md, skill prompts with rubrics/examples/voice guides, pipeline passes prior review context dynamically | No layered/scoped context per agent role; some skills (product-sense, curriculum) are thin on supporting context |
| Architectural Constraints | 3/5 | `CONTENT-SPEC.md` with 10 validation rules, `validate-content.sh` enforces structure, `validate-docs.sh` checks path references | Validation scripts are on-demand only (no hooks/CI). No constraints on review output format. No CI pipeline at all. |
| Entropy Management | 3/5 | `validate-docs.sh` checks CLAUDE.md path references against disk, `validate-content.sh` checks spec conformance | Scripts are manual-run only. No git hooks installed (`.git/hooks/` has only samples). No scheduled cleanup. CLAUDE.md had drifted significantly before today's update. |
| Verification & Feedback | 4/5 | Self-verification checklists on all 4 coaching skills, `content/feedback/TEMPLATE.md` for structured post feedback, `performance-log.md` with breakout formula derived from data, `synthesize-feedback.md` pipeline to close the loop | Feedback directory has only the template — no actual feedback reports filed yet. Synthesis pipeline exists but has never run. Loop is designed but not yet closed. |
| Agent Ergonomics | 4/5 | 12 slash commands, pipeline decomposed into 10+ single-purpose prompt files, skills are composable (validate calls pm-research sub-skills), clear human-in-the-loop checkpoints | No parallel agent execution. No explicit failure recovery paths in pipeline prompts. Brain hooks scaffolded but not active. |

---

## What's Working Well

1. **Prompt-driven pipeline architecture** (`src/pipeline/*.md`) — Textbook harness engineering. Each pipeline stage is a declarative prompt with explicit prerequisites, tool access, and output format. The coaching pipeline (`process-queue` → `process-ticket` → skill → review file) is a clean agent workflow.

2. **Coaching skills are fully instrumented** — All 4 coaching skills have prompt + rubric + examples (input/output pairs) + self-verification checklists. The star-coach has 10 self-check dimensions. This is the strongest harness in the project.

3. **Content output spec with mechanical validation** — `CONTENT-SPEC.md` defines 10 validation rules, and `validate-content.sh` enforces them programmatically. This is the constraint → enforcement pattern that harness engineering calls for.

4. **Prior review context in pipeline** — `process-ticket.md` Step 6c searches for prior reviews from the same student and passes them to the coach skill. This is dynamic context engineering — the agent's input improves with each use.

---

## Improvement Plan

### 1. Activate validation as git hooks (Constraints + Entropy)

**Current:** `validate-content.sh` and `validate-docs.sh` exist but must be run manually. `.git/hooks/` has only sample files. No CI.

**Target:** Pre-commit hook runs both validators. Bad content and stale doc references are caught before they enter the repo.

**First step:** Create `.git/hooks/pre-commit` that runs `scripts/validate-content.sh` and `scripts/validate-docs.sh`, exiting non-zero on failures.

**Effort:** quick-win

### 2. File actual feedback reports to close the feedback loop (Verification)

**Current:** `content/feedback/TEMPLATE.md` exists. `synthesize-feedback.md` pipeline is built. `performance-log.md` has historical data. But the `content/feedback/` directory has zero actual feedback files — the loop is open.

**Target:** At least 5-10 feedback reports filed for published posts. Then run `synthesize-feedback.md` to produce actionable prompt refinements.

**First step:** Pick your 3-5 most recent published posts, fill in a feedback report for each using the template.

**Effort:** medium (requires human data — can't be automated)

### 3. Add output format constraints to review files (Constraints)

**Current:** Content posts have `CONTENT-SPEC.md` + validation. But coaching review output in `reviews/` has no equivalent spec or validation — review file structure is enforced only by the pipeline prompt instructions, not mechanically.

**Target:** Create a `reviews/REVIEW-SPEC.md` defining required sections (Tier, Review Notes, Comments, Zendesk Response) and a `validate-reviews.sh` that checks conformance.

**First step:** Examine 3-4 existing review files in `reviews/`, extract the common structure, codify it as a spec.

**Effort:** medium

### 4. Add failure recovery to pipeline prompts (Ergonomics)

**Current:** Pipeline prompts (process-queue, process-ticket) describe the happy path but don't specify what to do when things fail — e.g., Google Doc is inaccessible, extraction returns empty, skill produces malformed output.

**Target:** Each pipeline prompt has an explicit "Error Handling" section defining recovery actions: skip and log, retry with fallback, create manual-review placeholder.

**First step:** Add error handling to `process-ticket.md` for the three most common failure modes (doc inaccessible, extraction empty, skill output malformed).

**Effort:** quick-win

### 5. Schedule entropy checks (Entropy)

**Current:** `validate-docs.sh` catches drift but only when someone remembers to run it. CLAUDE.md had drifted significantly before today's session.

**Target:** Weekly scheduled run of both validation scripts (via launchd since the project already uses it for the Telegram bot), with output saved to a log file for review.

**First step:** Create a launchd plist in `scripts/` that runs `validate-docs.sh && validate-content.sh` weekly, writing output to a timestamped log.

**Effort:** quick-win

---

## Reference

Based on the harness engineering framework from [OpenAI](https://openai.com/index/harness-engineering/), which defines three core dimensions: context engineering, architectural constraints, and entropy management. This review extends the framework with verification/feedback and agent ergonomics dimensions to better capture the full harness surface area.
