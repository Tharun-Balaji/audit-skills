#!/usr/bin/env bash
set -euo pipefail

TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

# Isolate all install locations the CLI may use.
export HOME="$TEST_HOME/home"
export CODEX_HOME="$TEST_HOME/.codex"
mkdir -p "$HOME" "$CODEX_HOME"

REPO_SLUG="${1:-}"
REF_NAME="${2:-main}"
SKILL_PATH="${3:-skills}"

if [[ -z "$REPO_SLUG" ]]; then
  echo "Usage: $0 <owner/repo> [ref] [path]"
  exit 2
fi

echo "Testing npx skills add for ${REPO_SLUG} (ref=${REF_NAME}, path=${SKILL_PATH})"

# Use non-interactive flags so CI doesn't block on agent selection prompts.
npx -y skills add "$REPO_SLUG" --ref "$REF_NAME" --path "$SKILL_PATH" --yes --global

# Accept both potential install roots used by skills tooling.
candidates=(
  "$CODEX_HOME/skills/audit-skills"
  "$HOME/.codex/skills/audit-skills"
  "$HOME/.agents/skills/audit-skills"
)

installed_skill_dir=""
for candidate in "${candidates[@]}"; do
  if [[ -d "$candidate" ]]; then
    installed_skill_dir="$candidate"
    break
  fi
done

if [[ -z "$installed_skill_dir" ]]; then
  echo "::error::Could not find installed skill directory in expected locations"
  printf 'Checked:\n- %s\n' "${candidates[@]}"
  exit 1
fi

echo "Detected installed skill at: $installed_skill_dir"

if [[ ! -f "$installed_skill_dir/SKILL.md" ]]; then
  echo "::error::Installed skill missing SKILL.md"
  exit 1
fi

if [[ ! -f "$installed_skill_dir/references/vulnerability-checklist.md" ]]; then
  echo "::error::Installed skill missing vulnerability checklist reference"
  exit 1
fi

if [[ ! -f "$installed_skill_dir/references/report-template.md" ]]; then
  echo "::error::Installed skill missing report template reference"
  exit 1
fi

echo "npx skills add installation test passed."
