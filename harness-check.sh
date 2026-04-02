#!/usr/bin/env bash
#
# harness-check.sh — Automated objective validation for harness engineering reviews
#
# Runs the automatable subset of the 16-point discovery checklist against any repo.
# Produces both human-readable output and a JSON report.
#
# Usage:
#   bash harness-check.sh                  # Run against current directory
#   bash harness-check.sh /path/to/repo    # Run against a specific repo
#   bash harness-check.sh --json           # JSON output only
#   bash harness-check.sh /path --json     # Both: specific repo + JSON only

set -uo pipefail

# --- Arguments ---
REPO_DIR="."
JSON_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --json) JSON_ONLY=true ;;
    *) REPO_DIR="$arg" ;;
  esac
done

if [ ! -d "$REPO_DIR" ]; then
  echo "Error: $REPO_DIR does not exist or is not a directory" >&2
  exit 1
fi

REPO_DIR="$(cd "$REPO_DIR" && pwd)"

if [ ! -d "$REPO_DIR/.git" ] && [ ! -f "$REPO_DIR/.git" ]; then
  echo "Error: $REPO_DIR is not a git repository" >&2
  exit 1
fi

# --- Helpers ---
found_files=()
check_results=""

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; }
info() { echo "  INFO: $1"; }

add_json_check() {
  local check_num="$1" name="$2" status="$3" detail="$4"
  if [ -n "$check_results" ]; then
    check_results="${check_results},"
  fi
  # Escape backslashes, quotes, and newlines in detail for valid JSON
  detail=$(echo "$detail" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')
  check_results="${check_results}
    {\"check\": $check_num, \"name\": \"$name\", \"status\": \"$status\", \"detail\": \"$detail\"}"
}

# --- Check 1: Root Agent Configuration [A] ---
check1_agent_config() {
  local header="Check 1: Root Agent Configuration"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local config_files=("CLAUDE.md" "AGENTS.md" ".cursorrules" ".cursorignore")
  local found=0
  local details=""
  local total_lines=0

  for f in "${config_files[@]}"; do
    if [ -f "$REPO_DIR/$f" ]; then
      local lines
      lines=$(wc -l < "$REPO_DIR/$f" | tr -d ' ')
      total_lines=$((total_lines + lines))
      found=$((found + 1))
      $JSON_ONLY || pass "$f exists ($lines lines)"
      details="${details}${f}(${lines}L) "
    fi
  done

  # Check .claude/ directory
  if [ -d "$REPO_DIR/.claude" ]; then
    found=$((found + 1))
    $JSON_ONLY || pass ".claude/ directory exists"
    details="${details}.claude/ "
  fi

  # Check .claude/commands/
  local cmd_count=0
  if [ -d "$REPO_DIR/.claude/commands" ]; then
    cmd_count=$(find "$REPO_DIR/.claude/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    $JSON_ONLY || info ".claude/commands/ has $cmd_count command files"
    details="${details}commands:${cmd_count} "
  fi

  # Check for per-directory CLAUDE.md files (layered context)
  local nested_claude
  nested_claude=$(find "$REPO_DIR" -name "CLAUDE.md" -not -path "$REPO_DIR/CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$nested_claude" -gt 0 ]; then
    $JSON_ONLY || info "$nested_claude nested CLAUDE.md files (layered context)"
    details="${details}nested:${nested_claude} "
  fi

  if [ "$found" -eq 0 ]; then
    $JSON_ONLY || fail "No agent configuration files found"
    add_json_check 1 "Root Agent Configuration" "fail" "No config files found"
  else
    add_json_check 1 "Root Agent Configuration" "pass" "$details total_lines:$total_lines"
  fi

  # Quality: check CLAUDE.md sections
  if [ -f "$REPO_DIR/CLAUDE.md" ]; then
    local has_overview=false has_structure=false has_commands=false has_conventions=false
    grep -qi "overview\|what.*is\|about" "$REPO_DIR/CLAUDE.md" && has_overview=true
    grep -qi "directory\|structure\|layout" "$REPO_DIR/CLAUDE.md" && has_structure=true
    grep -qi "command\|script\|build\|run" "$REPO_DIR/CLAUDE.md" && has_commands=true
    grep -qi "convention\|naming\|style\|pattern" "$REPO_DIR/CLAUDE.md" && has_conventions=true

    local sections=0
    $has_overview && sections=$((sections + 1))
    $has_structure && sections=$((sections + 1))
    $has_commands && sections=$((sections + 1))
    $has_conventions && sections=$((sections + 1))
    $JSON_ONLY || info "CLAUDE.md covers $sections/4 essentials (overview, structure, commands, conventions)"
  fi
}

# --- Check 3: Git Hooks [A] ---
check3_git_hooks() {
  local header="Check 3: Git Hooks"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local found=0
  local details=""

  # Non-sample hooks in .git/hooks/
  local git_dir
  if [ -f "$REPO_DIR/.git" ]; then
    # Submodule or worktree — resolve the actual git dir
    git_dir=$(cat "$REPO_DIR/.git" | sed 's/gitdir: //')
    [ "${git_dir:0:1}" != "/" ] && git_dir="$REPO_DIR/$git_dir"
  else
    git_dir="$REPO_DIR/.git"
  fi

  if [ -d "$git_dir/hooks" ]; then
    local active_hooks
    active_hooks=$(find "$git_dir/hooks" -type f -not -name "*.sample" 2>/dev/null | while read -r h; do [ -x "$h" ] && echo "$h"; done | wc -l | tr -d ' ')
    if [ "$active_hooks" -gt 0 ]; then
      found=$((found + 1))
      $JSON_ONLY || pass "$active_hooks active git hooks"
      details="${details}git-hooks:${active_hooks} "
    else
      $JSON_ONLY || fail "No active git hooks (only samples)"
    fi
  fi

  # Husky
  if [ -d "$REPO_DIR/.husky" ]; then
    local husky_hooks
    husky_hooks=$(find "$REPO_DIR/.husky" -type f -not -name ".gitignore" -not -name "husky.sh" 2>/dev/null | wc -l | tr -d ' ')
    found=$((found + 1))
    $JSON_ONLY || pass ".husky/ directory with $husky_hooks hooks"
    details="${details}husky:${husky_hooks} "
  fi

  # pre-commit (Python)
  if [ -f "$REPO_DIR/.pre-commit-config.yaml" ]; then
    found=$((found + 1))
    $JSON_ONLY || pass ".pre-commit-config.yaml exists"
    details="${details}pre-commit-config "
  fi

  # lint-staged in package.json
  if [ -f "$REPO_DIR/package.json" ] && grep -q "lint-staged" "$REPO_DIR/package.json" 2>/dev/null; then
    found=$((found + 1))
    $JSON_ONLY || pass "lint-staged configured in package.json"
    details="${details}lint-staged "
  fi

  if [ "$found" -eq 0 ]; then
    $JSON_ONLY || fail "No git hooks or hook frameworks detected"
    add_json_check 3 "Git Hooks" "fail" "No hooks detected"
  else
    add_json_check 3 "Git Hooks" "pass" "$details"
  fi
}

# --- Check 4: CI/CD Configuration [A] ---
check4_cicd() {
  local header="Check 4: CI/CD Configuration"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local found=0
  local details=""

  if [ -d "$REPO_DIR/.github/workflows" ]; then
    local workflow_count
    workflow_count=$(find "$REPO_DIR/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
    found=$((found + 1))
    $JSON_ONLY || pass ".github/workflows/ with $workflow_count workflow files"
    details="${details}github-actions:${workflow_count} "
  fi

  for f in ".gitlab-ci.yml" "Jenkinsfile" "circle.yml" ".circleci/config.yml" ".buildkite/pipeline.yml"; do
    if [ -f "$REPO_DIR/$f" ]; then
      found=$((found + 1))
      $JSON_ONLY || pass "$f exists"
      details="${details}${f} "
    fi
  done

  if [ "$found" -eq 0 ]; then
    $JSON_ONLY || fail "No CI/CD configuration detected"
    add_json_check 4 "CI/CD Configuration" "fail" "No CI/CD config found"
  else
    add_json_check 4 "CI/CD Configuration" "pass" "$details"
  fi
}

# --- Check 5: Skills and Prompts [A] ---
check5_skills() {
  local header="Check 5: Skills and Prompts"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local skill_dirs=("src/skills" "skills" "prompts" "agents" ".claude/agents")
  local total_skills=0
  local with_rubric=0
  local with_examples=0
  local details=""

  for dir in "${skill_dirs[@]}"; do
    if [ -d "$REPO_DIR/$dir" ]; then
      # Count immediate subdirectories as skills
      local skills_in_dir
      skills_in_dir=$(find "$REPO_DIR/$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

      if [ "$skills_in_dir" -gt 0 ]; then
        $JSON_ONLY || info "$dir/ has $skills_in_dir skill directories"
        total_skills=$((total_skills + skills_in_dir))

        # Check each skill for rubric and examples
        while IFS= read -r skill_dir; do
          local name
          name=$(basename "$skill_dir")
          if [ -f "$skill_dir/rubric.md" ]; then
            with_rubric=$((with_rubric + 1))
          fi
          if [ -d "$skill_dir/examples" ]; then
            with_examples=$((with_examples + 1))
          fi
        done < <(find "$REPO_DIR/$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
      fi
    fi
  done

  # Also check for standalone prompt files
  local standalone_prompts=0
  for dir in "${skill_dirs[@]}"; do
    if [ -d "$REPO_DIR/$dir" ]; then
      local prompts_here
      prompts_here=$(find "$REPO_DIR/$dir" -maxdepth 1 -name "*.md" -name "*prompt*" 2>/dev/null | wc -l | tr -d ' ')
      standalone_prompts=$((standalone_prompts + prompts_here))
    fi
  done

  details="skills:${total_skills} with_rubric:${with_rubric} with_examples:${with_examples}"

  if [ "$total_skills" -eq 0 ]; then
    $JSON_ONLY || fail "No skill directories found"
    add_json_check 5 "Skills and Prompts" "fail" "No skills found"
  else
    $JSON_ONLY || pass "$total_skills skills ($with_rubric with rubrics, $with_examples with examples)"
    add_json_check 5 "Skills and Prompts" "pass" "$details"
  fi
}

# --- Check 6: Validation Scripts [A] ---
check6_validation() {
  local header="Check 6: Validation Scripts"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local found=0
  local details=""

  # Look in scripts/ directory
  if [ -d "$REPO_DIR/scripts" ]; then
    local validate_scripts
    validate_scripts=$(find "$REPO_DIR/scripts" -name "validate-*" -o -name "check-*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$validate_scripts" -gt 0 ]; then
      found=$((found + validate_scripts))
      $JSON_ONLY || pass "$validate_scripts validation scripts in scripts/"
      details="${details}scripts/:${validate_scripts} "
    fi
  fi

  # Look for output spec files
  local specs
  specs=$(find "$REPO_DIR" -maxdepth 2 -name "*-SPEC.md" -o -name "*-spec.md" -o -name "*.schema.json" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
  if [ "$specs" -gt 0 ]; then
    $JSON_ONLY || info "$specs output spec files found"
    details="${details}specs:${specs} "
  fi

  if [ "$found" -eq 0 ]; then
    $JSON_ONLY || fail "No validation scripts found"
    add_json_check 6 "Validation Scripts" "fail" "No validation scripts found"
  else
    add_json_check 6 "Validation Scripts" "pass" "$details"
  fi
}

# --- Check 12: Secrets and Security Patterns [A] ---
check12_secrets() {
  local header="Check 12: Secrets and Security Patterns"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local score=0
  local details=""

  # Check .gitignore for secret patterns
  if [ -f "$REPO_DIR/.gitignore" ]; then
    local has_env=false has_creds=false has_secrets=false
    grep -q "\.env" "$REPO_DIR/.gitignore" 2>/dev/null && has_env=true
    grep -qi "credential" "$REPO_DIR/.gitignore" 2>/dev/null && has_creds=true
    grep -qi "secret" "$REPO_DIR/.gitignore" 2>/dev/null && has_secrets=true

    if $has_env; then
      score=$((score + 1))
      $JSON_ONLY || pass ".gitignore excludes .env files"
      details="${details}.env-excluded "
    else
      $JSON_ONLY || fail ".gitignore does not exclude .env files"
    fi
  else
    $JSON_ONLY || fail "No .gitignore file found"
    add_json_check 12 "Secrets and Security" "fail" "No .gitignore"
    return
  fi

  # Check for pre-commit secret scanning
  local has_scanning=false
  if [ -f "$REPO_DIR/.pre-commit-config.yaml" ] && grep -qi "secret\|detect-secrets\|gitleaks\|trufflehog" "$REPO_DIR/.pre-commit-config.yaml" 2>/dev/null; then
    has_scanning=true
  fi
  # Check for GitHub secret scanning or gitleaks config
  if [ -f "$REPO_DIR/.gitleaks.toml" ] || [ -f "$REPO_DIR/.gitleaks.yaml" ]; then
    has_scanning=true
  fi

  if $has_scanning; then
    score=$((score + 1))
    $JSON_ONLY || pass "Secret scanning configured"
    details="${details}scanning "
  else
    $JSON_ONLY || info "No automated secret scanning detected"
    details="${details}no-scanning "
  fi

  if [ "$score" -gt 0 ]; then
    add_json_check 12 "Secrets and Security" "pass" "$details"
  else
    add_json_check 12 "Secrets and Security" "fail" "$details"
  fi
}

# --- Check 14: Slash Commands and Entry Points [A] ---
check14_commands() {
  local header="Check 14: Slash Commands and Entry Points"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local cmd_count=0
  local details=""

  if [ -d "$REPO_DIR/.claude/commands" ]; then
    cmd_count=$(find "$REPO_DIR/.claude/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    $JSON_ONLY || pass "$cmd_count slash commands in .claude/commands/"
    details="${details}claude-commands:${cmd_count} "
  fi

  # Check Makefile targets
  if [ -f "$REPO_DIR/Makefile" ]; then
    local targets
    targets=$(grep -c "^[a-zA-Z_-]*:" "$REPO_DIR/Makefile" 2>/dev/null || echo 0)
    $JSON_ONLY || info "Makefile with $targets targets"
    details="${details}make-targets:${targets} "
  fi

  # Check package.json scripts
  if [ -f "$REPO_DIR/package.json" ]; then
    local scripts
    scripts=$(grep -c '"[a-zA-Z:_-]*":' "$REPO_DIR/package.json" 2>/dev/null || echo 0)
    if [ "$scripts" -gt 0 ]; then
      $JSON_ONLY || info "package.json with ~$scripts script entries"
      details="${details}npm-scripts:${scripts} "
    fi
  fi

  if [ "$cmd_count" -eq 0 ]; then
    $JSON_ONLY || fail "No slash commands found"
    add_json_check 14 "Slash Commands" "fail" "No slash commands. $details"
  else
    add_json_check 14 "Slash Commands" "pass" "$details"
  fi
}

# --- Check 16: Production Monitoring [A] ---
check16_monitoring() {
  local header="Check 16: Production Monitoring"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "=== $header ==="

  local found=0
  local details=""

  # Look for performance/quality tracking files
  local perf_files
  perf_files=$(find "$REPO_DIR" -maxdepth 3 -name "performance-log*" -o -name "quality-*" -o -name "metrics-*" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
  if [ "$perf_files" -gt 0 ]; then
    found=$((found + 1))
    $JSON_ONLY || pass "$perf_files performance/quality tracking files"
    details="${details}perf-files:${perf_files} "
  fi

  # Look for monitoring/logging config
  for f in "monitoring/" "logging/" ".monitoring" "observability/" "dashboards/"; do
    if [ -d "$REPO_DIR/$f" ] || [ -f "$REPO_DIR/$f" ]; then
      found=$((found + 1))
      $JSON_ONLY || pass "$f exists"
      details="${details}${f} "
    fi
  done

  # Look for output directories (basic observability — outputs are at least saved)
  local output_dirs=("reviews" "output" "generated" "content" "results")
  local saved_outputs=0
  for dir in "${output_dirs[@]}"; do
    if [ -d "$REPO_DIR/$dir" ]; then
      saved_outputs=$((saved_outputs + 1))
    fi
  done
  if [ "$saved_outputs" -gt 0 ]; then
    $JSON_ONLY || info "$saved_outputs output directories (outputs are persisted)"
    details="${details}output-dirs:${saved_outputs} "
  fi

  # Look for feedback directories with actual data
  if [ -d "$REPO_DIR/content/feedback" ] || [ -d "$REPO_DIR/feedback" ]; then
    local feedback_dir
    [ -d "$REPO_DIR/content/feedback" ] && feedback_dir="$REPO_DIR/content/feedback" || feedback_dir="$REPO_DIR/feedback"
    local feedback_count
    feedback_count=$(find "$feedback_dir" -name "*.md" -not -name "TEMPLATE*" -not -name "README*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$feedback_count" -gt 0 ]; then
      $JSON_ONLY || pass "$feedback_count feedback reports filed"
      details="${details}feedback-reports:${feedback_count} "
    else
      $JSON_ONLY || info "Feedback directory exists but no reports filed"
      details="${details}feedback-empty "
    fi
  fi

  if [ "$found" -eq 0 ] && [ "$saved_outputs" -eq 0 ]; then
    $JSON_ONLY || fail "No monitoring, logging, or quality tracking detected"
    add_json_check 16 "Production Monitoring" "fail" "No monitoring detected"
  else
    add_json_check 16 "Production Monitoring" "pass" "$details"
  fi
}

# --- Summary ---
print_summary() {
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "============================================"
  $JSON_ONLY || echo "  Harness Check Summary: $(basename "$REPO_DIR")"
  $JSON_ONLY || echo "============================================"

  # Count passes and fails
  local passes fails
  passes=$(echo "$check_results" | grep -c '"pass"' || true)
  fails=$(echo "$check_results" | grep -c '"fail"' || true)
  local total=$((passes + fails))

  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "  Checks run: $total"
  $JSON_ONLY || echo "  Passed: $passes"
  $JSON_ONLY || echo "  Failed: $fails"
  $JSON_ONLY || echo ""
  $JSON_ONLY || echo "  Note: This covers objective checks only (8 of 16)."
  $JSON_ONLY || echo "  Subjective checks (quality assessment, feedback depth,"
  $JSON_ONLY || echo "  architecture docs, git history analysis) require the"
  $JSON_ONLY || echo "  full /harness-review skill evaluation."
  $JSON_ONLY || echo ""

  # JSON output
  local project_name
  project_name=$(basename "$REPO_DIR")
  local today
  today=$(date +%Y-%m-%d)

  cat <<ENDJSON
{
  "project_name": "$project_name",
  "date": "$today",
  "tool": "harness-check.sh",
  "tool_version": "1.0",
  "framework_version": "2.0",
  "repo_path": "$REPO_DIR",
  "checks_run": $total,
  "checks_passed": $passes,
  "checks_failed": $fails,
  "note": "Covers 8 of 16 discovery checks (objective items only). Run /harness-review for full evaluation.",
  "checks": [$check_results
  ]
}
ENDJSON
}

# --- Main ---
$JSON_ONLY || echo "Harness Check — $(basename "$REPO_DIR")"
$JSON_ONLY || echo "Running automated discovery checks against: $REPO_DIR"

check1_agent_config
check3_git_hooks
check4_cicd
check5_skills
check6_validation
check12_secrets
check14_commands
check16_monitoring
print_summary
