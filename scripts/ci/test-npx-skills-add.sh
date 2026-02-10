#!/usr/bin/env bash
set -euo pipefail

TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

export CODEX_HOME="$TEST_HOME/.codex"
mkdir -p "$CODEX_HOME"

REPO_SLUG="${1:-}"
REF_NAME="${2:-main}"
SKILL_PATH="${3:-skills}"

if [[ -z "$REPO_SLUG" ]]; then
  echo "Usage: $0 <owner/repo> [ref] [path]"
  exit 2
fi

echo "Testing npx skills add for ${REPO_SLUG} (ref=${REF_NAME}, path=${SKILL_PATH})"

# Run the documented installation command from README with an explicit ref.
npx -y skills add "$REPO_SLUG" --ref "$REF_NAME" --path "$SKILL_PATH"

installed_skill_dir="$CODEX_HOME/skills/audit-skills"
if [[ ! -d "$installed_skill_dir" ]]; then
  echo "::error::Expected installed skill directory at $installed_skill_dir"
  exit 1
fi

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
