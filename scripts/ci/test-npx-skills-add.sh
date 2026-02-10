#!/usr/bin/env bash
set -euo pipefail

TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

# Isolate all install locations the CLI may use.
export HOME="$TEST_HOME/home"
export CODEX_HOME="$TEST_HOME/.codex"
mkdir -p "$HOME" "$CODEX_HOME"

REPO_SLUG="${1:-Tharun-Balaji/audit-skills}"
SKILL_PATH="${2:-skills}"

if [[ -z "$REPO_SLUG" ]]; then
  echo "Usage: $0 [owner/repo] [path]"
  exit 2
fi

echo "Testing documented install command: npx skills add ${REPO_SLUG} --path ${SKILL_PATH}"

# Run the documented command in non-interactive mode for CI stability.
set +e
install_output="$(npx -y skills add "$REPO_SLUG" --path "$SKILL_PATH" --yes --global 2>&1)"
install_status=$?
set -e

if [[ "$install_status" -ne 0 ]]; then
  echo "$install_output"

  # Some environments block npm registry access/policies; treat as an infra limitation, not a packaging regression.
  if grep -Eq '(E403|403 Forbidden|ENOTFOUND|ETIMEDOUT|ECONNRESET|EAI_AGAIN)' <<<"$install_output"; then
    echo "::warning::Skipping install validation due to external npm/network restriction."
    exit 0
  fi

  echo "::error::npx skills add command failed"
  exit "$install_status"
fi

# Accept both potential install roots used by skills tooling.
install_roots=(
  "$CODEX_HOME/skills"
  "$HOME/.codex/skills"
  "$HOME/.agents/skills"
)

installed_count=0
for root in "${install_roots[@]}"; do
  [[ -d "$root" ]] || continue

  while IFS= read -r skill_dir; do
    [[ -d "$skill_dir" ]] || continue

    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
      echo "::error::Installed skill missing SKILL.md ($skill_dir)"
      exit 1
    fi

    if [[ ! -d "$skill_dir/references" ]]; then
      echo "::error::Installed skill missing references directory ($skill_dir)"
      exit 1
    fi

    md_count="$(find "$skill_dir/references" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
    if [[ "$md_count" -eq 0 ]]; then
      echo "::error::Installed skill has no markdown references ($skill_dir/references)"
      exit 1
    fi

    echo "Validated installed skill at: $skill_dir"
    installed_count=$((installed_count + 1))
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)
done

if [[ "$installed_count" -eq 0 ]]; then
  echo "::error::Could not find installed skill directory in expected locations"
  printf 'Checked roots:\n- %s\n' "${install_roots[@]}"
  exit 1
fi

echo "npx skills add installation test passed for $installed_count installed skill(s)."
