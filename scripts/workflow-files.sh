#!/usr/bin/env bash
#
# Shared workflow file mapping. Sourced by install.sh, verify.sh and compare.sh.
# Keep this file free of side effects; it must not write to any path.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'This file is sourced, not executed.\n' >&2
  exit 64
fi

template_sources=(
  'AGENTS.template.md'
  'CLAUDE.template.md'
  'PROJECT_PROFILE.template.md'
  'WORKFLOW_BASELINE.yaml'
  'openSpec/config.template.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
)

installed_destinations=(
  'AGENTS.md'
  'CLAUDE.md'
  'PROJECT_PROFILE.md'
  'WORKFLOW_BASELINE.yaml'
  'openSpec/config.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
)

# Directory trees are copied recursively. `.agents/skills/` is the canonical
# source and `.claude/skills/` mirrors the same skill for Claude Code.
review_skill_name='running-code-review-gate'
review_skill_canonical_tree='.agents/skills/running-code-review-gate'
review_skill_mirror_tree='.claude/skills/running-code-review-gate'

template_tree_sources=(
  "$review_skill_canonical_tree"
  "$review_skill_mirror_tree"
)

installed_tree_destinations=(
  "$review_skill_canonical_tree"
  "$review_skill_mirror_tree"
)

installed_directories=(
  'openSpec/changes/archive'
)

# Review gate skill contract. `.agents` is canonical; `.claude` mirrors every
# required file and must not contain the Codex-only metadata file.
review_skill_required_files=(
  'SKILL.md'
  'references/review-contract.md'
  'references/reviewer-brief.md'
)
review_skill_canonical_only_files=(
  'agents/openai.yaml'
)

# Lists every file under a directory tree, sorted by relative path.
list_tree_files() {
  local tree_root=$1
  (
    cd "$tree_root"
    find . -type f -print | LC_ALL=C sort
  ) | while IFS= read -r tree_path; do
    printf '%s\n' "${tree_path#./}"
  done
}

# Validates the exact file set of a template tree. The canonical tree may
# contain Codex-only metadata; the mirror must not.
validate_template_tree() {
  local tree_root=$1
  local allow_canonical_only=$2
  local expected_files=("${review_skill_required_files[@]}")
  local tree_file
  local allowed
  local matched

  if [[ "$allow_canonical_only" == 'true' ]]; then
    expected_files+=("${review_skill_canonical_only_files[@]}")
  fi

  for allowed in "${expected_files[@]}"; do
    if [[ ! -f "$tree_root/$allowed" ]]; then
      printf 'Template skill file is missing: %s/%s\n' "$tree_root" "$allowed" >&2
      return 1
    fi
  done

  while IFS= read -r tree_file; do
    matched='false'
    for allowed in "${expected_files[@]}"; do
      if [[ "$tree_file" == "$allowed" ]]; then
        matched='true'
        break
      fi
    done
    if [[ "$matched" == 'false' ]]; then
      printf 'Template skill contains unexpected file: %s/%s\n' "$tree_root" "$tree_file" >&2
      return 1
    fi
  done < <(list_tree_files "$tree_root")
}
