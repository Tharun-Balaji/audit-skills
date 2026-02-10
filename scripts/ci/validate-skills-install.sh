#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="${1:-$ROOT_DIR/skills}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "::error::skills directory not found at $SKILLS_DIR"
  exit 1
fi

shopt -s nullglob
skill_paths=("$SKILLS_DIR"/*)
if [[ ${#skill_paths[@]} -eq 0 ]]; then
  echo "::error::No skills found under $SKILLS_DIR"
  exit 1
fi

for skill_path in "${skill_paths[@]}"; do
  [[ -d "$skill_path" ]] || continue
  skill_name="$(basename "$skill_path")"
  echo "Validating skill: $skill_name"

  symlink_path="$(find "$skill_path" -type l -print -quit)"
  if [[ -n "$symlink_path" ]]; then
    echo "::error file=$symlink_path::Symlinks are not allowed in packaged skills"
    exit 1
  fi

  skill_file="$skill_path/SKILL.md"
  if [[ ! -f "$skill_file" ]]; then
    echo "::error file=$skill_file::Missing SKILL.md"
    exit 1
  fi

  # Validate YAML frontmatter starts on line 1 and has a closing delimiter.
  first_line="$(head -n 1 "$skill_file")"
  if [[ "$first_line" != "---" ]]; then
    echo "::error file=$skill_file::SKILL.md must start with YAML frontmatter delimiter '---' on line 1"
    exit 1
  fi

  second_delim_line="$(awk 'NR>1 && /^---$/ { print NR; exit }' "$skill_file")"
  if [[ -z "$second_delim_line" ]]; then
    echo "::error file=$skill_file::Missing closing YAML frontmatter delimiter '---'"
    exit 1
  fi

  if ! grep -q '^name:' "$skill_file"; then
    echo "::error file=$skill_file::Frontmatter missing required 'name' field"
    exit 1
  fi

  # Validate referenced local markdown resources exist.
  while IFS= read -r rel_path; do
    if [[ "$rel_path" == /* ]] || [[ "$rel_path" == *".."* ]]; then
      echo "::error file=$skill_file::Unsafe resource path '$rel_path' (absolute/traversal paths are not allowed)"
      exit 1
    fi

    resource_path="$skill_path/$rel_path"
    if [[ ! -f "$resource_path" ]]; then
      echo "::error file=$skill_file::Referenced resource '$rel_path' does not exist"
      exit 1
    fi
  done < <(sed -n 's|.*\](\([^)]*\.md\)).*|\1|p' "$skill_file" | rg -v '^(https?://|#)' || true)

  # Simulate a local install by copying the skill folder into an installation root.
  install_root="$TMP_DIR/mnt/skills/user"
  mkdir -p "$install_root"
  cp -R "$skill_path" "$install_root/"

  installed_skill="$install_root/$skill_name"
  [[ -f "$installed_skill/SKILL.md" ]] || { echo "::error::Installed SKILL.md missing for $skill_name"; exit 1; }

done

echo "All skills passed installation validation."
