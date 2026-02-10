#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/scripts/ci/validate-skills-install.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

make_skill() {
  local dir="$1"
  local link_target="$2"
  mkdir -p "$dir/references"
  cat > "$dir/SKILL.md" <<SKILL
---
name: $(basename "$dir")
description: test
---

# Test Skill

See [ref]($link_target)
SKILL
  cat > "$dir/references/ref.md" <<'REF'
# ref
REF
}

expect_pass() {
  local label="$1"
  local path="$2"
  if "$VALIDATOR" "$path" >/dev/null 2>&1; then
    echo "PASS: $label"
  else
    echo "::error::$label failed unexpectedly"
    "$VALIDATOR" "$path" || true
    exit 1
  fi
}

expect_fail() {
  local label="$1"
  local path="$2"
  if "$VALIDATOR" "$path" >/dev/null 2>&1; then
    echo "::error::$label passed unexpectedly"
    exit 1
  else
    echo "PASS: $label (blocked as expected)"
  fi
}

# Baseline valid skill should pass.
valid_root="$TMP_DIR/valid"
mkdir -p "$valid_root"
make_skill "$valid_root/safe-skill" "references/ref.md"
expect_pass "safe skill" "$valid_root"

# Absolute markdown link should be blocked.
abs_root="$TMP_DIR/absolute"
mkdir -p "$abs_root"
make_skill "$abs_root/abs-skill" "/tmp/evil.md"
expect_fail "absolute path markdown link" "$abs_root"

# Traversal markdown link should be blocked.
traversal_root="$TMP_DIR/traversal"
mkdir -p "$traversal_root"
make_skill "$traversal_root/traversal-skill" "../outside.md"
expect_fail "traversal markdown link" "$traversal_root"

# Symlinked content in skill package should be blocked.
symlink_root="$TMP_DIR/symlink"
mkdir -p "$symlink_root"
make_skill "$symlink_root/symlink-skill" "references/ref.md"
ln -s /etc/hosts "$symlink_root/symlink-skill/references/hosts-link.md"
expect_fail "symlink in packaged skill" "$symlink_root"

echo "Security regression checks passed."
