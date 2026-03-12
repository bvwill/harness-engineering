# Harness Engineering Review — Discovery Checklist

Run through each check in order. Record what you find. This standardizes discovery across projects and ensures nothing gets missed.

## How to Use

For each check: record Found/Not Found, the file path or location, and a one-line quality note. Complete all 15 checks before assigning a tier or scoring any dimension.

---

## Checks

### 1. Root Agent Configuration
**Look for:** `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.claude/` directory, `.claude/commands/`
**Record:** Which files exist, approximate line count, last modified date (from git log)
**Quality signals:** Does it cover project overview? Directory structure? Commands? Conventions?

### 2. Package and Build Configuration
**Look for:** `package.json` (scripts section), `Makefile`, `Cargo.toml`, `pyproject.toml`, `Dockerfile`
**Record:** What build/test/lint commands are defined
**Quality signals:** Are there lint, test, and build scripts? Is there a dev vs prod distinction?

### 3. Git Hooks
**Look for:** `.git/hooks/` (non-sample files), `.husky/`, `lint-staged` config in package.json, `pre-commit-config.yaml`
**Record:** Which hooks are active, what they run
**Quality signals:** Do hooks enforce validation before commit? Are they actually installed (not just sample files)?

### 4. CI/CD Configuration
**Look for:** `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `circle.yml`, `.buildkite/`
**Record:** What pipelines exist, what they check (lint, test, build, deploy)
**Quality signals:** Do pipelines run on PR? Do they block merge on failure?

### 5. Skills and Prompts
**Look for:** `src/skills/`, `prompts/`, `agents/`, `.claude/agents/`, any directory containing `.md` files that look like agent instructions
**Record:** Number of skills, which have supporting files (rubrics, examples, voice guides)
**Quality signals:** Do skills have more than just a prompt? Are there rubrics, examples, self-verification?

### 6. Validation Scripts
**Look for:** `scripts/validate-*`, `scripts/check-*`, any script that validates output format or content
**Record:** What they validate, how they're triggered (manual, hook, CI)
**Quality signals:** Do they run automatically or require manual invocation?

### 7. Output Directories
**Look for:** Directories where agent-produced artifacts land (e.g., `reviews/`, `content/`, `output/`, `generated/`)
**Record:** Directory structure, naming conventions, whether outputs follow a consistent format
**Quality signals:** Is there an output spec (like CONTENT-SPEC.md)? Are outputs organized by date or category?

### 8. Test Directories and Coverage
**Look for:** `tests/`, `__tests__/`, `*.test.*`, `*.spec.*`, coverage config (`.nycrc`, `jest.config`, `pytest.ini`)
**Record:** What test frameworks are used, approximate test count, coverage thresholds if configured
**Quality signals:** Are there tests specifically for agent-generated output? Coverage requirements?

### 9. Feedback and Performance Tracking
**Look for:** `feedback/`, `performance-log*`, feedback templates, quality tracking files, metrics dashboards
**Record:** What feedback mechanisms exist, whether they contain actual data or just templates
**Quality signals:** Has feedback been captured? Has it flowed back into prompts? Is there evidence of iteration?

### 10. Design and Architecture Docs
**Look for:** `docs/`, `architecture.md`, `design/`, ADRs (Architecture Decision Records), `docs/plans/`
**Record:** What documentation exists, how current it is (check git log dates)
**Quality signals:** Are docs versioned and maintained? Do they match the current implementation?

### 11. Access Control Indicators
**Look for:** `CODEOWNERS`, branch protection rules (check `.github/` or repo settings), contributor guidelines
**Record:** Whether critical paths have designated reviewers, whether branch protection is configured
**Quality signals:** Are there different access tiers? Is review required for merges?

### 12. Secrets and Security Patterns
**Look for:** `.gitignore` entries for `.env`, `credentials`, `secrets`; pre-commit secret scanning config; vault config
**Record:** How secrets are managed (env vars, vault, hardcoded)
**Quality signals:** Are secrets excluded from version control? Is there automated secret scanning?

### 13. MCP Server Configuration
**Look for:** `mcp-config.json`, `mcp.json`, `.claude/mcp-servers/`, MCP server source directories
**Record:** What MCP servers exist, what capabilities they provide
**Quality signals:** Are MCP servers documented? Do they have write restrictions where appropriate?

### 14. Slash Commands and Entry Points
**Look for:** `.claude/commands/`, CLI scripts, Makefiles with common workflows
**Record:** Number and purpose of slash commands or entry points
**Quality signals:** Do common workflows have ergonomic entry points? Are arguments documented?

### 15. Git History Analysis
**Run:** `git log --oneline -20` and `git shortlog -sn --all | head -10`
**Record:** Number of contributors, frequency of commits, whether commits show agent-generated patterns (e.g., "Co-Authored-By: Claude")
**Quality signals:** How active is the repo? Is there evidence of multi-contributor workflows?

---

## Tier Assignment

After completing all 15 checks, count the signals:

**Tier 1 (Foundations):** Checks 1-2 show sparse or no agent configuration. Few or no skills. No automated enforcement. Solo contributor.

**Tier 2 (Team-ready):** Comprehensive agent instructions (check 1). Validation scripts exist (check 6). Multiple skills with some supporting context (check 5). Some feedback mechanisms (check 9).

**Tier 3 (Systematic):** Layered agent context (check 1). Automated enforcement via hooks/CI (checks 3-4). 5+ skills with rubrics/examples (check 5). Feedback captured and synthesized (check 9). Multi-agent patterns visible (check 15).

State: "This project presents as Tier X. I will evaluate at that depth. Override with --tier if you want a different level."
