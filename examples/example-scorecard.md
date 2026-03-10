# Harness Engineering Review: Weekly Coaching Summary Generator

**Overall Maturity: Level 2 (Team-Ready)**
**Composite Score: 3.0 / 5.0**

---

## Maturity Scorecard

| Dimension | Score | Key Strength | Key Gap |
|-----------|-------|-------------|---------|
| Context Engineering | 4/5 | Comprehensive CLAUDE.md, skill prompts reference rubrics and examples | Design docs reference planned features that are already built |
| Architectural Constraints | 2/5 | Output templates define expected structure | No mechanical validation. Format compliance depends entirely on model following instructions |
| Entropy Management | 2/5 | Documentation exists and is organized | No automated drift detection. Two pipeline prompts reference a config file that was renamed |
| Verification & Feedback | 3/5 | Self-review checklist in each skill prompt. Human approves before external action | No structured feedback capture. Quality cannot compound without a feedback loop |
| Agent Ergonomics | 4/5 | Clean pipeline decomposition. Each skill is focused and single-purpose | No recovery path if a mid-pipeline step fails. Manual restart from the beginning |
| **Overall** | **3.0/5** | | |

**Maturity Level: Level 2 (Team-Ready)**

---

## What's Working Well

- **Context is well-organized.** The CLAUDE.md gives the agent everything it needs to understand the project: directory structure, commands, conventions, current status. Skill prompts include rubrics and annotated examples, not just instructions. This is better than 90% of PM-built projects.

- **Pipeline decomposition is solid.** Each step (fetch tickets, extract content, run review, generate summary) is a separate prompt with a clear handoff. No 500-line monolith prompts trying to do everything at once. Each skill has a focused scope.

- **Human checkpoint in the right place.** Reviews go to a markdown file for human approval before any external action. Nothing auto-posts, auto-sends, or auto-publishes. This is exactly the right design for a coaching tool where quality matters more than speed.

- **Voice guides ground the output.** The coaching voice document captures actual patterns from real sessions, not aspirational descriptions. This prevents the generic-AI-content problem that kills most content generation tools.

---

## Gaps

### No output validation (Constraints, high impact)
If the model generates a malformed review (missing sections, wrong format, skipped rubric dimensions), nothing catches it. The prompt says "follow this format" but there is no mechanical enforcement. Output quality depends entirely on model compliance, which drifts over time as prompts get longer and more complex.

### Stale documentation (Entropy, medium impact)
The CLAUDE.md references "Phase 3: Morning Briefing" as planned, but early implementation exists in `src/briefing/`. Two pipeline prompts reference a config file that was renamed 3 weeks ago. These inconsistencies degrade context quality for the agent and will compound as the project grows.

### No feedback loop (Verification, high impact)
Reviews get generated and approved, but there is no mechanism for capturing what was good or bad about each review. The human edits the output and moves on. Quality cannot compound if there is no structured feedback flowing back into the prompts. After 50 reviews, the system should be noticeably better than after 5. Right now it is not.

---

## Prioritized Improvements

### 1. Add output validation script (Constraints, quick win)
**Current state:** Prompt says "follow this format." No enforcement.
**Target state:** A script that checks generated reviews for required sections, minimum length, and format compliance. Runs as a post-generation step.
**First step:** Write a script that parses review output and checks for the 5 required sections. Run it after each generation. Takes 30 minutes and catches 80% of format drift.

### 2. Fix stale references (Entropy, quick win)
**Current state:** CLAUDE.md phase descriptions don't match reality. Two config file references are broken.
**Target state:** All documentation reflects current project state. Monthly review cadence.
**First step:** Update CLAUDE.md phase descriptions. Fix the two broken config paths. Set a monthly calendar reminder to re-read CLAUDE.md and check for drift.

### 3. Add structured feedback capture (Verification, medium effort)
**Current state:** Human reviews output, edits it, and moves on. No record of what changed or why.
**Target state:** After approving or editing a review, a brief note is saved: what was changed and why. Notes accumulate and can be synthesized back into prompt refinement.
**First step:** Create a feedback template (3 fields: what was changed, why, and quality rating 1-5). Save alongside each review output. Even a simple markdown log compounds over time.

---

*Reviewed by harness-review skill. Scores reflect project state at time of review.*
