# Harness Engineering

A Claude Code skill that scores your AI-built project on the six things that determine whether it works reliably or needs you babysitting every output.

## The Problem

You built a tool with Claude Code or Cursor. It worked great in your demo. Then you handed it to your team, or ran it on real data, and the output was inconsistent. Sometimes great, sometimes wrong, sometimes structured differently than last time.

The issue isn't the AI model. It's everything around it: the instructions, constraints, validation, and feedback loops that tell the model what "good" looks like and catch it when it drifts. Most PM-built tools are missing half of this scaffolding. So every output needs a human reviewing it, which defeats the purpose of building the tool in the first place.

Harness engineering is the practice of designing that environment. The better your harness, the more autonomy you can give your AI tools. The worse it is, the more you're stuck checking every output by hand.

## Who This Is For

PMs who build internal tools, automations, or workflows with AI coding assistants and want those tools to be reliable without constant engineering oversight.

If you've ever thought "this works when I run it but breaks when anyone else does," your harness needs work.

## How It Works

Run the skill against any project. It reads your repo (agent instructions, prompts, validation scripts, feedback artifacts, output directories, monitoring config) and scores it across 6 dimensions of harness maturity. You get a scorecard, specific strengths and gaps, and a prioritized improvement plan.

The skill does its own discovery. It reads your files, maps your structure, and identifies what you have and what's missing. You don't need to explain your project.

## When to Use It

- After building a v1 of any AI-assisted tool or workflow
- Before handing a tool off to your team
- When your tool starts producing inconsistent results
- When you want to move from "it works for me" to "it works reliably"

## Usage

```
/harness-review
```

Run it from the root of any project. The skill will read your repo and produce a scored maturity assessment.

## The 6 Dimensions

### 1. Context Engineering (high weight)

Does your AI agent have access to everything it needs, discoverable in the repo?

This is the foundation. If your CLAUDE.md is sparse, your prompts don't reference examples, and your design docs are outdated, the agent is guessing. Good context engineering means the agent finds what it needs without asking you. Great context engineering means different agents get tailored context for their specific role.

### 2. Architectural Constraints (high weight)

Does your system prevent bad output mechanically, or are you relying on "please follow the format" in your prompt?

Instructions alone aren't constraints. Constraints are validation scripts that check output structure, pre-commit hooks that enforce rules, output specs that define what "correct" looks like. The question is: if the agent produces malformed output, does something catch it before it reaches a user?

### 3. Entropy Management (medium weight)

Does your system self-correct over time, or does documentation drift from reality?

Every project accumulates entropy. Your CLAUDE.md says Phase 3 is "planned" but you built it two months ago. Your prompt references a file that got renamed. Entropy management is about automated checks that catch this drift, not relying on someone to notice.

### 4. Verification and Feedback (high weight)

Does output quality compound over time through feedback loops?

Most PM-built tools have one feedback mechanism: you look at the output and decide if it's good. That's a start, but it doesn't compound. Good verification means self-check prompts, structured feedback capture, and performance tracking. Great verification means past feedback actually flows back into improving the prompts.

### 5. Agent Ergonomics (medium weight)

Is the system designed for the AI to succeed? Is work decomposed well?

A single 500-line prompt that handles everything is fragile. Decomposed pipelines with focused skills, clear handoffs, and human-in-the-loop checkpoints are resilient. This dimension measures whether you've designed the work in a way that plays to the model's strengths.

### 6. Operational Monitoring (medium weight)

Can you detect when agent output quality degrades in production?

Most PM-built tools have no observability. Output gets produced and consumed, and nobody knows if quality is slipping until a user complains. Good monitoring means you're tracking quality signals over time. Great monitoring means you have alerts that fire when quality degrades and production data that flows back into improving the harness.

## Scoring

Each dimension is scored 1-5. Most projects score 2-3 on first review. That's normal.

| Level | Name | What It Means |
|-------|------|---------------|
| Level 1 | Individual | Basic instructions and linting. Works for you, fragile for anyone else. |
| Level 2 | Team-ready | Solid docs, CI constraints, validation. Reliable enough to share. |
| Level 3 | Systematic | Custom enforcement, feedback loops, performance tracking. Self-improving. |

## Example Output

The skill adapts its depth to your project's maturity:

- **Tier 1 (Foundations):** ~1 page. See [`examples/tier-1-review.md`](examples/tier-1-review.md) — a solo CLI tool with sparse agent configuration.
- **Tier 2 (Team-ready):** ~2-3 pages. See [`examples/tier-2-review.md`](examples/tier-2-review.md) — a productivity system with validation scripts and feedback mechanisms.
- **Tier 3 (Systematic):** ~4-5 pages. See [`examples/tier-3-review.md`](examples/tier-3-review.md) — a multi-agent skill library with automated enforcement and closed feedback loops.

Most projects score Tier 1 or 2 on first review. That is normal and useful. The value is in the specific gaps and the prioritized fix list, not the number.

## Repo Structure

```
prompt.md                      # Skill prompt (the evaluator instructions)
rubric.md                      # Scoring criteria — the authority on what each score means
discovery-checklist.md         # 16-point structured discovery process
reference-benchmarks.md        # Calibration benchmarks for scoring consistency
self-verification.md           # Pre-presentation checklist with anti-inflation guardrails
output-schema.json             # JSON Schema for structured scorecard output
examples/
  tier-1-review.md             # Example: compact Foundations review
  tier-2-review.md             # Example: standard Team-ready review
  tier-3-review.md             # Example: comprehensive Systematic review
README.md                      # This file
```

## Why a Scorecard Instead of Pass/Fail

Harness maturity isn't binary. A project can have excellent context engineering but no validation. A scorecard shows you exactly where to invest your next hour of improvement, rather than just telling you "needs work."

## Why These 6 Dimensions

They map to the six ways AI-built tools break in practice:

1. **Context** breaks when the agent doesn't know what you know
2. **Constraints** break when nothing enforces output quality mechanically
3. **Entropy** breaks when your docs and code drift apart over weeks
4. **Verification** breaks when there's no feedback loop improving quality over time
5. **Ergonomics** break when the task is too big or too tangled for the agent to handle cleanly
6. **Monitoring** breaks when nobody knows the agent is producing bad output in production

Fix them in roughly that order. Context and constraints are the highest leverage. Entropy, ergonomics, and monitoring matter more as the project matures.

## The Philosophy

"Harness engineering" comes from a simple observation: the model is usually capable enough. What makes AI tools unreliable isn't the model, it's the environment around it.

Think of it like managing a team. A good manager doesn't micromanage every output. They set clear expectations, build processes that catch mistakes, create feedback loops that improve quality over time, and design work so people can succeed independently. Harness engineering is the same thing, applied to AI agents.

The better your harness, the less you need to review. The less you review, the more tools you can run. That's how PMs scale AI from "one cool prototype" to "a system that actually saves time."
