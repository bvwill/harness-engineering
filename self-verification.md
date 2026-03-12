# Harness Engineering Review — Self-Verification

Run this checklist BEFORE presenting the review to the user. Every item must pass. If any item fails, fix it before presenting.

---

## Evidence Checks

- [ ] Every dimension score cites at least one specific file path as evidence
- [ ] Every score above 3 cites at least 2 specific files as evidence
- [ ] Every score of 4 or 5 includes a justification: "This is exceptional because..." with comparison to the reference benchmarks in `reference-benchmarks.md`
- [ ] No score is based on assumed behavior. If you scored something, you read the file or ran the check.

## Anti-Inflation Check

- [ ] If more than 2 dimensions score 4+, re-read each justification against the rubric criteria. Are you being generous? Most projects score 2-3 on first review.
- [ ] Compare overall score against the reference benchmarks. Is it plausible that this project is more mature than bv-workdesk (3.6/5)?
- [ ] No dimension scored 5 unless you can demonstrate the feature working, not just existing.

## Completeness Checks

- [ ] All 15 discovery checklist items were checked (not skipped)
- [ ] The tier assignment was stated and justified before scoring began
- [ ] "What's Working Well" section credits at least 2 specific strengths with file references
- [ ] Every improvement in the plan has all required fields: dimension, current state, target state, why it matters, first step, effort tag
- [ ] Every improvement has a concrete first step (not "consider improving" or "evaluate options")
- [ ] Improvements are prioritized by impact, not listed in dimension order

## Security Check (Tier 2+)

- [ ] Checked .gitignore for secret exclusion patterns
- [ ] Checked for pre-commit secret scanning
- [ ] Checked for branch protection indicators
- [ ] Noted security findings in the Architectural Constraints sub-score

## Consulting Context Check (when team signals detected)

- [ ] If git history shows multiple contributors, each dimension includes an "Organizational Context" note on team-level impact
- [ ] If CODEOWNERS exists, access control patterns are noted
- [ ] Improvements connect gaps to consequences ("What breaks without it"), not just checklist items

## Format Check

- [ ] Report follows the tier-appropriate output format (Tier 1: ~1 page, Tier 2: ~2-3 pages, Tier 3: ~4-5 pages)
- [ ] Scorecard table is complete with all dimensions
- [ ] Sub-scores are included for Tier 2+ reviews
- [ ] "What to focus on to reach Tier X+1" section is included
