#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
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

  if ! awk 'NR==1 { next } /^---$/ { exit(found ? 0 : 1) } /^name:[[:space:]]*[^[:space:]].*/ { found=1 } END { exit(found ? 0 : 1) }' "$skill_file"; then
    echo "::error file=$skill_file::Frontmatter missing required 'name' field"
    exit 1
  fi

  # Validate local markdown links resolve from every markdown file in the skill.
  while IFS= read -r markdown_file; do
    while IFS= read -r rel_path; do
      # Ignore anchors and external links.
      [[ "$rel_path" =~ ^# ]] && continue
      [[ "$rel_path" =~ ^https?:// ]] && continue

      if [[ "$rel_path" == /* ]] || [[ "$rel_path" == *".."* ]]; then
        echo "::error file=$markdown_file::Unsafe markdown link '$rel_path' (absolute/traversal paths are not allowed)"
        exit 1
      fi

      clean_path="${rel_path%%#*}"
      clean_path="${clean_path%%\?*}"
      [[ -z "$clean_path" ]] && continue

      resource_path="$(cd "$(dirname "$markdown_file")" && realpath -m "$clean_path")"
      if [[ "$resource_path" != "$skill_path"/* ]] || [[ ! -f "$resource_path" ]]; then
        echo "::error file=$markdown_file::Referenced resource '$rel_path' does not exist within skill folder"
        exit 1
      fi
    done < <(sed -n 's|.*\](\([^)]*\.md\)).*|\1|p' "$markdown_file" || true)
  done < <(find "$skill_path" -type f -name '*.md' | sort)

  # Simulate a local install by copying the skill folder into an installation root.
  install_root="$TMP_DIR/mnt/skills/user"
  mkdir -p "$install_root"
  cp -R "$skill_path" "$install_root/"

  installed_skill="$install_root/$skill_name"
  [[ -f "$installed_skill/SKILL.md" ]] || { echo "::error::Installed SKILL.md missing for $skill_name"; exit 1; }

done

echo "All skills passed installation validation."
