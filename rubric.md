# Harness Engineering Review — Scoring Rubric

Score each dimension using the tier-appropriate criteria below. Every score must cite specific files or patterns as evidence.

## Scoring Rules

- No dimension can score above 3 without citing at least 2 specific files as evidence
- No dimension can score 5 unless the evaluator can demonstrate it working (not just existing)
- If more than 2 dimensions score 4+, re-verify each against the reference benchmarks before proceeding

---

## Dimension 1: Context Engineering (weight: high)

### Tier 1 Criteria

| Score | Requirements | Evidence Needed |
|-------|-------------|----------------|
| 1 | No project-level agent instructions. No CLAUDE.md, AGENTS.md, or .cursorrules. | Confirmed absence of all config files |
| 2 | CLAUDE.md or equivalent exists but is missing 2+ of: project overview, directory structure, commands, conventions | File path + list of missing sections |
| 3 | CLAUDE.md contains all of: (a) project overview stating what the project does, (b) directory structure section with at least top-level paths, (c) commands section with build/test/run instructions, (d) conventions section covering at minimum naming and file organization. Missing any one drops to 2. | File path + confirmation of all 4 sections |
| 4 | N/A at Tier 1 | |
| 5 | N/A at Tier 1 | |

### Tier 2 Criteria (includes Tier 1, adds sub-scores)

All Tier 1 criteria apply. Additionally score these sub-dimensions:

**Sub-score: Skill Context**
| Score | Requirements |
|-------|-------------|
| 1 | Skills have only a prompt file with no supporting context |
| 2 | Some skills have rubrics OR examples, but not both |
| 3 | Key skills have prompt + rubric + examples. Voice guides or reference materials exist where relevant. |

**Sub-score: Pipeline Context**
| Score | Requirements |
|-------|-------------|
| 1 | Pipelines do not reference prior outputs or cross-project context |
| 2 | Some pipelines pass basic context (e.g., file paths) |
| 3 | Pipelines pass prior outputs, cross-references, and relevant history as part of agent input |

**Sub-score: Staleness**
| Score | Requirements |
|-------|-------------|
| 1 | Context files have not been updated in 60+ days while code has changed significantly |
| 2 | Context files updated within 30-60 days, minor drift from reality |
| 3 | Context files updated within 30 days, accurately reflect current project state |

### Tier 3 Criteria (includes Tier 2, adds depth)

All Tier 2 criteria apply. Additionally evaluate:

- **Scoped context:** Do different agents or pipelines receive tailored context for their role? (e.g., AGENTS.md with role-specific instructions, per-directory CLAUDE.md files)
- **Context pruning:** Is there evidence of unused context being removed? Are deprecated skills cleaned up?
- **Staleness ratio:** What percentage of context files were updated in the last 30 days vs. total context files? >80% = strong. <50% = concerning.

---

## Dimension 2: Architectural Constraints (weight: high)

### Tier 1 Criteria

| Score | Requirements | Evidence Needed |
|-------|-------------|----------------|
| 1 | No output format specs. No linting. No validation of agent output. | Confirmed absence |
| 2 | Basic linting exists (eslint, prettier, etc.) but no agent-output-specific validation | Linter config file path |
| 3 | Output format spec defines required structure (e.g., CONTENT-SPEC.md, template files) AND at least one validation script checks conformance | Spec file path + validation script path |
| 4 | N/A at Tier 1 | |
| 5 | N/A at Tier 1 | |

### Tier 2 Criteria (adds sub-scores)

All Tier 1 criteria apply. Additionally:

**Sub-score: Enforcement Automation**
| Score | Requirements |
|-------|-------------|
| 1 | Validation exists but is manual-run only |
| 2 | Some validation runs via hooks or CI, but coverage is incomplete |
| 3 | All output validation runs automatically (pre-commit hooks or CI). Failures block delivery. |

**Sub-score: Testing Coverage**
| Score | Requirements |
|-------|-------------|
| 1 | No tests for agent-generated outputs |
| 2 | Some tests exist but no coverage thresholds or systematic approach |
| 3 | Agent outputs have test coverage. Coverage thresholds are defined. Tests run automatically. |

**Sub-score: Security Basics** (Tier 2 addition)
| Score | Requirements |
|-------|-------------|
| 1 | No evidence of secrets management (.env files possibly in repo, no .gitignore for secrets) |
| 2 | .gitignore excludes secrets. No automated secret scanning. |
| 3 | .gitignore excludes secrets AND pre-commit secret scanning or GitHub Secret Protection is active AND branch protection requires PR review |

### Tier 3 Criteria (adds depth)

All Tier 2 criteria apply. Additionally evaluate:

- **Architectural fitness functions:** Are there tests that verify architecture boundaries (e.g., dependency direction rules, module isolation)?
- **LLM-based auditors:** Are there prompts or tools that use LLMs to audit agent output beyond format checks?
- **Self-healing tests:** Do tests auto-update when code changes break selectors or patterns?

---

## Dimension 3: Entropy Management (weight: medium)

### Tier 1 Criteria

| Score | Requirements | Evidence Needed |
|-------|-------------|----------------|
| 1 | No consistency checks. Referenced paths in docs may not exist. | Example of broken reference |
| 2 | Some manual review catches drift, but no automation | Evidence of manual cleanup in git history |
| 3 | At least one script validates doc/code consistency (referenced paths exist, status sections are current). Can be run on-demand. | Script path + what it checks |

### Tier 2 Criteria (adds depth)

All Tier 1 criteria apply. Additionally:

| Score | Requirements |
|-------|-------------|
| 4 | Consistency checks run automatically via hooks or CI. Stale docs are flagged proactively. Run frequency is at least weekly. |

### Tier 3 Criteria (adds depth)

| Score | Requirements |
|-------|-------------|
| 5 | Background agents or scheduled jobs scan for entropy and either fix issues or open cleanup tasks. Pattern enforcement detects new inconsistencies as they are introduced. |

---

## Dimension 4: Verification & Feedback (weight: high)

### Tier 1 Criteria

| Score | Requirements | Evidence Needed |
|-------|-------------|----------------|
| 1 | No verification. Agent output is accepted as-is with no review step. | Absence of review process |
| 2 | Human reviews agent output before use, but no structured feedback capture | Evidence of review practice (PR reviews, manual checks) |
| 3 | Agent prompts include self-verification checklists AND human feedback is captured in a structured format (templates with ratings or categories) | Prompt file showing self-check + feedback template path |

### Tier 2 Criteria (adds sub-scores)

All Tier 1 criteria apply. Additionally:

**Sub-score: Self-Verification**
| Score | Requirements |
|-------|-------------|
| 1 | No self-check in prompts |
| 2 | Some prompts include basic "verify your output" instructions |
| 3 | Prompts include structured self-verification checklists with specific dimensions to check |

**Sub-score: Feedback Capture**
| Score | Requirements |
|-------|-------------|
| 1 | No feedback templates or tracking |
| 2 | Templates exist but contain no actual feedback data |
| 3 | Templates exist AND contain actual feedback. At least 5 feedback entries have been filed. |

**Sub-score: Performance Tracking**
| Score | Requirements |
|-------|-------------|
| 1 | No quality metrics tracked |
| 2 | Some metrics tracked informally (notes, logs) |
| 3 | Quality metrics tracked over time with visible trends (performance logs, engagement data, quality ratings) |

**Sub-score: QA Coverage** (Tier 2 addition)
| Score | Requirements |
|-------|-------------|
| 1 | No tests for agent output quality |
| 2 | Manual spot-checking of output quality |
| 3 | Systematic quality checks: golden datasets, output comparisons, or automated scoring |

### Tier 3 Criteria (adds depth)

All Tier 2 criteria apply. Additionally evaluate:

- **Feedback synthesis:** Does feedback flow back into prompts? Is there a pipeline or process that takes captured feedback and produces prompt refinements?
- **Multi-layer verification:** Is verification more than one step? (e.g., self-check + peer review + automated scoring)
- **Eval frameworks:** Are there golden datasets, A/B comparisons, or variance analysis for skill output?
- **Closed-loop evidence:** Can you trace a specific prompt improvement back to specific feedback? Show the chain.

---

## Dimension 5: Agent Ergonomics (weight: medium)

### Tier 1 Criteria

| Score | Requirements | Evidence Needed |
|-------|-------------|----------------|
| 1 | Monolithic prompts. Agent must handle everything in one pass. No decomposition. | Prompt file showing single large instruction |
| 2 | Some decomposition exists (e.g., separate prompt files) but handoffs between stages are ad-hoc | File paths showing partial decomposition |
| 3 | Pipeline is decomposed into clear stages. Each skill/prompt has a focused scope. Human-in-the-loop checkpoints exist at critical decision points. | Pipeline file paths + evidence of checkpoints |

### Tier 2 Criteria (adds sub-scores)

All Tier 1 criteria apply. Additionally:

**Sub-score: Skill Modularity**
| Score | Requirements |
|-------|-------------|
| 1 | Skills are standalone with no composition |
| 2 | Some skills reference other skills but composition is informal |
| 3 | Skills are composable. Pipelines call sub-skills. Clear input/output contracts between stages. |

**Sub-score: Entry Points**
| Score | Requirements |
|-------|-------------|
| 1 | No slash commands or ergonomic entry points |
| 2 | Some slash commands exist but coverage is incomplete |
| 3 | Common workflows have slash command wrappers with documented arguments |

**Sub-score: Human-in-the-Loop**
| Score | Requirements |
|-------|-------------|
| 1 | No explicit human checkpoints in agent workflows |
| 2 | Implicit checkpoints (agent pauses for input) but not designed |
| 3 | Explicit human-in-the-loop checkpoints at critical points. The system is designed so nothing posts, sends, or modifies external systems without approval. |

### Tier 3 Criteria (adds depth)

All Tier 2 criteria apply. Additionally evaluate:

- **Multi-agent coordination:** Can agents work in parallel? Are agent roles clearly differentiated? Is context scoped per agent?
- **Failure recovery:** Does failure in one pipeline stage cascade to other stages, or is it isolated? Are there explicit recovery paths?
- **Agent-to-agent communication:** Can agents hand off work to each other? Is there a coordination pattern (team, queue, event)?

---

## Tier 3 Dedicated Sections

These are not scored 1-5. They produce qualitative assessments included as dedicated sections in the Tier 3 report.

### Security & RBAC Assessment

Evaluate:
- CODEOWNERS with designated reviewers for critical paths
- Role-based access tiers (engineer, PM-developer, CS-analyst, etc.)
- Secrets management stack (vault vs .env vs hardcoded)
- Preview environments for safe testing
- Audit trail completeness (who changed what, when, why)
- Compliance posture (SOC2, HIPAA, PCI-DSS indicators)

Output: Narrative assessment with specific findings and recommendations.

### Multi-Agent Coordination Assessment

Evaluate against the everything-claude-code benchmark:
- Number and differentiation of agent roles
- Parallel execution support
- Context scoping per agent (tailored vs shared)
- Communication patterns between agents
- Continuous learning loops (do agents improve from prior runs?)

Output: Maturity comparison against reference implementation.

### Change Management Readiness Assessment

Evaluate (organizational, not technical):
- Evidence of multi-role contribution in git history
- Onboarding documentation for new contributor types
- Workflow change documentation
- Training materials or getting-started guides
- Evidence of gradual expansion (e.g., tiered access rollout)

Output: Readiness narrative with recommendations. Most relevant for consulting engagements.
