# Harness Engineering Review — Reference Benchmarks

Use these benchmarks to calibrate your scoring. When in doubt about a score, ask: "Is this project closer to the Tier 2 or Tier 3 benchmark on this dimension?"

---

## Tier 2 Benchmark: bv-workdesk

**Overall Score:** 3.6/5
**Maturity Level:** Level 2 (bordering Level 3) — Team-ready
**Review date:** 2026-03-10
**Full review:** `docs/plans/2026-03-10-harness-review.md`

### What Makes It Tier 2

**Context Engineering (4/5):**
- Comprehensive CLAUDE.md (~200 lines) covering project overview, directory structure, commands, conventions, environment variables, and OAuth setup
- 12+ skill prompts, 4 coaching skills with full instrumentation (prompt + rubric + examples + self-verification)
- Pipeline prompts pass prior review context dynamically (process-ticket.md Step 6c searches for prior reviews from same student)
- Gap: no layered/scoped context per agent role. Some skills (product-sense, curriculum) have thin supporting context.

**Architectural Constraints (3/5):**
- CONTENT-SPEC.md with 10 validation rules, enforced by validate-content.sh
- validate-docs.sh checks CLAUDE.md path references against disk
- Gap: validation is on-demand only (no hooks/CI). No constraints on review output format. No CI pipeline.

**Entropy Management (3/5):**
- validate-docs.sh catches drift in referenced paths
- Gap: scripts are manual-run only. No git hooks installed. CLAUDE.md had drifted significantly before the review session.

**Verification & Feedback (4/5):**
- Self-verification checklists on all 4 coaching skills (star-coach has 10 self-check dimensions)
- content/feedback/TEMPLATE.md for structured post feedback
- performance-log.md with breakout formula derived from engagement data
- synthesize-feedback.md pipeline designed to close the loop
- Gap: feedback directory has only the template. Zero actual feedback reports filed. Synthesis pipeline has never run. Loop is designed but not closed.

**Agent Ergonomics (4/5):**
- 12 slash commands for common workflows
- Pipeline decomposed into 10+ single-purpose prompt files
- Skills are composable (validate calls pm-research sub-skills)
- Clear human-in-the-loop checkpoints (nothing posts without approval)
- Gap: no parallel agent execution. No explicit failure recovery paths. Brain hooks scaffolded but not active.

### Use This Benchmark When

A project has comprehensive documentation, multiple skills, validation scripts, and feedback mechanisms designed but not yet fully closed. This is the "infrastructure is built, loops need closing" stage.

---

## Tier 3 Benchmark: everything-claude-code

**Estimated Score:** 4.2+/5
**Maturity Level:** Level 3 — Systematic
**Source:** github.com/affaan-m/everything-claude-code (analyzed 2026-03-10)

### What Makes It Tier 3

**Context Engineering (5/5):**
- Layered context: project-level CLAUDE.md + per-directory agent instructions + role-specific agent definitions
- 65+ skills with supporting context, rubrics, and examples
- Context is scoped per agent role (different agents receive tailored instructions)
- Active context pruning: deprecated skills are removed, not left to rot

**Architectural Constraints (4/5):**
- Multiple validation layers: linting + format checking + LLM-based auditing
- Pre-commit hooks and CI enforce constraints automatically
- Output format specs for multiple output types
- Constraint violations block delivery

**Entropy Management (4/5):**
- Automated consistency checks run on commit
- Background processes detect drift between docs and implementation
- Scheduled cleanup tasks maintain alignment

**Verification & Feedback (5/5):**
- Multi-layer verification: self-check + peer review + automated scoring
- Eval frameworks with golden datasets for skill output comparison
- Continuous learning loops: feedback is captured, synthesized, and flows back into prompts
- Closed-loop evidence: prompt improvements traceable to specific feedback

**Agent Ergonomics (5/5):**
- 16+ subagents with clearly differentiated roles
- Multi-agent orchestration with parallel execution
- Failure in one stage does not cascade (isolated recovery paths)
- Agent-to-agent communication and handoff patterns
- Composable skill architecture with clear input/output contracts

### Use This Benchmark When

A project has automated enforcement, multi-agent coordination, continuous feedback loops, and evidence that the system improves itself over time. This is the "self-correcting system" stage. Very few projects reach this level.

---

## Calibration Guidelines

| Overall Score Range | What It Means | How Common |
|---------------------|---------------|------------|
| 1.0-1.5 | Minimal harness. Agent instructions barely exist. | Very common for new projects |
| 1.5-2.5 | Basic harness. Docs exist but no enforcement. | Common for early-stage teams |
| 2.5-3.5 | Solid harness. Docs + validation + some feedback. Team-ready. | Uncommon. bv-workdesk sits here. |
| 3.5-4.5 | Strong harness. Automated enforcement + closed feedback loops. | Rare. everything-claude-code sits here. |
| 4.5-5.0 | Exceptional harness. Self-correcting, multi-agent, fully instrumented. | Very rare. Reserve for systems that demonstrably improve themselves. |

If a project you are reviewing scores above 3.5, verify each 4+ dimension against these benchmarks. If it scores above 4.5, something may be wrong with your evaluation.
