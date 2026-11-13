#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: compare.sh --target <installed-project> [--base <old-template-snapshot>]

Read-only comparison between an installed workflow project and this template.
With --base, classifies local changes, template changes, and conflicts.
Without --base, only reports unchanged or differs (two-way comparison).
EOF
}

target_dir=''
base_dir=''
base_provided='false'

while (($# > 0)); do
  case "$1" in
    --target)
      if (($# < 2)); then
        printf 'Missing value for --target.\n' >&2
        usage >&2
        exit 64
      fi
      target_dir=$2
      shift 2
      ;;
    --base)
      if (($# < 2)); then
        printf 'Missing value for --base.\n' >&2
        usage >&2
        exit 64
      fi
      base_provided='true'
      base_dir=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  printf 'Missing required --target argument.\n' >&2
  usage >&2
  exit 64
fi

if [[ "$base_provided" == 'true' && -z "$base_dir" ]]; then
  printf 'Missing value for --base.\n' >&2
  usage >&2
  exit 64
fi

if [[ ! -d "$target_dir" ]]; then
  printf 'Target directory does not exist or is not a directory: %s\n' "$target_dir" >&2
  exit 66
fi
if [[ ! -r "$target_dir" || ! -x "$target_dir" ]]; then
  printf 'Target directory is not readable and searchable: %s\n' "$target_dir" >&2
  exit 66
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
project_root=$(cd "$script_dir/.." && pwd -P)
template_root="$project_root/templates/project-workflow"
target_root=$(cd "$target_dir" && pwd -P)

source "$script_dir/workflow-files.sh"

for source in "${template_sources[@]}"; do
  if [[ ! -f "$template_root/$source" ]]; then
    printf 'Template source is missing: %s\n' "$template_root/$source" >&2
    exit 70
  fi
done

for tree_index in "${!template_tree_sources[@]}"; do
  tree="$template_root/${template_tree_sources[$tree_index]}"
  if [[ ! -d "$tree" ]]; then
    printf 'Template directory is missing: %s\n' "$tree" >&2
    exit 70
  fi
  if [[ "$tree_index" -eq 0 ]]; then
    canonical_only='true'
  else
    canonical_only='false'
  fi
  if ! validate_template_tree "$tree" "$canonical_only"; then
    exit 70
  fi
done

base_root=''
if [[ -n "$base_dir" ]]; then
  if [[ ! -d "$base_dir" ]]; then
    printf 'Base directory does not exist or is not a directory: %s\n' "$base_dir" >&2
    exit 66
  fi
  if [[ ! -r "$base_dir" || ! -x "$base_dir" ]]; then
    printf 'Base directory is not readable and searchable: %s\n' "$base_dir" >&2
    exit 66
  fi
  base_root=$(cd "$base_dir" && pwd -P)
  if [[ ! -f "$base_root/AGENTS.template.md" ]]; then
    printf 'Base directory is not a template snapshot (missing AGENTS.template.md): %s\n' "$base_root" >&2
    exit 66
  fi
fi

require_regular_readable() {
  local path=$1
  local label=$2
  if [[ ! -f "$path" ]]; then
    printf '%s is not a regular file: %s\n' "$label" "$path" >&2
    exit 66
  fi
  if [[ ! -r "$path" ]]; then
    printf '%s is not readable: %s\n' "$label" "$path" >&2
    exit 66
  fi
}

read_baseline_version() {
  local version
  version=$(ruby -e 'require "yaml"; value = YAML.load_file(ARGV.fetch(0))["workflow_version"]; print value' "$1" 2>/dev/null) || version='unknown'
  if [[ -z "$version" ]]; then
    version='unknown'
  fi
  printf '%s\n' "$version"
}

printf 'Template: %s\n' "$template_root"
printf 'Target: %s\n' "$target_root"
if [[ -n "$base_root" ]]; then
  printf 'Base: %s\n' "$base_root"
else
  printf 'Base: none (two-way comparison; local and template changes cannot be separated)\n'
fi
printf 'Target baseline: %s\n' "$(read_baseline_version "$target_root/WORKFLOW_BASELINE.yaml")"
if [[ -n "$base_root" ]]; then
  printf 'Base baseline: %s\n' "$(read_baseline_version "$base_root/WORKFLOW_BASELINE.yaml")"
fi
printf 'Template baseline: %s\n' "$(read_baseline_version "$template_root/WORKFLOW_BASELINE.yaml")"
printf '\n'
printf '%-14s %-48s %s\n' 'STATUS' 'FILE' 'NOTE'
printf '%-14s %-48s %s\n' '--------------' '------------------------------------------------' '----'

append_note() {
  if [[ -n "$note" ]]; then
    note="$note; $1"
  else
    note=$1
  fi
}

compare_file() {
  local source_path=$1
  local base_rel=$2
  local destination_rel=$3
  local destination_path="$target_root/$destination_rel"
  local status=''
  local note=''

  if [[ ! -e "$destination_path" ]]; then
    status='missing'
    note='not installed'
  else
    require_regular_readable "$destination_path" 'Target path'

    if [[ -z "$base_root" ]]; then
      if cmp -s "$destination_path" "$source_path"; then
        status='unchanged'
      else
        status='differs'
        note='two-way diff; verify manually'
      fi
    else
      local base_path="$base_root/$base_rel"
      if [[ ! -e "$base_path" ]]; then
        status='base-missing'
        note='missing from base snapshot'
      else
        require_regular_readable "$base_path" 'Base path'

        local local_changed='false'
        local template_changed='false'
        if ! cmp -s "$destination_path" "$base_path"; then
          local_changed='true'
        fi
        if ! cmp -s "$base_path" "$source_path"; then
          template_changed='true'
        fi

        if [[ "$local_changed" == 'false' && "$template_changed" == 'false' ]]; then
          status='unchanged'
        elif [[ "$local_changed" == 'true' && "$template_changed" == 'false' ]]; then
          status='ours-only'
        elif [[ "$local_changed" == 'false' && "$template_changed" == 'true' ]]; then
          status='theirs-only'
        elif cmp -s "$destination_path" "$source_path"; then
          status='converged'
        else
          status='both-changed'
        fi
      fi
    fi
  fi

  case "$destination_rel" in
    AGENTS.md|CLAUDE.md|PROJECT_PROFILE.md|openSpec/config.yaml)
      append_note 'manual: project-specific'
      ;;
    WORKFLOW_BASELINE.yaml)
      append_note 'metadata: update after merge'
      ;;
  esac

  printf '%-14s %-48s %s\n' "$status" "$destination_rel" "$note"
}

for index in "${!template_sources[@]}"; do
  compare_file "$template_root/${template_sources[$index]}" \
    "${template_sources[$index]}" \
    "${installed_destinations[$index]}"
done

for tree_index in "${!template_tree_sources[@]}"; do
  tree_source="$template_root/${template_tree_sources[$tree_index]}"
  tree_destination=${installed_tree_destinations[$tree_index]}
  while IFS= read -r tree_file; do
    compare_file "$tree_source/$tree_file" \
      "${template_tree_sources[$tree_index]}/$tree_file" \
      "$tree_destination/$tree_file"
  done < <(list_tree_files "$tree_source")

  if [[ -d "$target_root/$tree_destination" ]]; then
    while IFS= read -r target_file; do
      target_present='false'
      while IFS= read -r template_file; do
        if [[ "$target_file" == "$template_file" ]]; then
          target_present='true'
          break
        fi
      done < <(list_tree_files "$tree_source")
      if [[ "$target_present" == 'false' ]]; then
        printf '%-14s %-48s %s\n' 'local-extra' "$tree_destination/$target_file" 'not in template; review manually'
      fi
    done < <(list_tree_files "$target_root/$tree_destination")
  fi
done

for directory_rel in "${installed_directories[@]}"; do
  if [[ -d "$target_root/$directory_rel" ]]; then
    printf '%-14s %-48s %s\n' 'unchanged' "$directory_rel/" 'directory'
  else
    printf '%-14s %-48s %s\n' 'missing' "$directory_rel/" 'directory'
  fi
done

printf '\nNo files were written. Merge manually and update the baseline only after verification.\n'
