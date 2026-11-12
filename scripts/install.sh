#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage: ./scripts/install.sh --target <project-directory> [--dry-run]' \
    '' \
    'Installs the project workflow without overwriting existing files.' \
    'If any destination file exists, the command reports all conflicts and writes nothing.' \
    'If a destination parent is a symbolic link or not a directory, the command reports the unsafe path and writes nothing.'
}

target_dir=''
dry_run='false'

while (($# > 0)); do
  case "$1" in
    --target)
      if (($# < 2)); then
        usage >&2
        exit 64
      fi
      target_dir=$2
      shift 2
      ;;
    --dry-run)
      dry_run='true'
      shift
      ;;
    --help|-h)
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

if [[ ! -d "$target_dir" ]]; then
  printf 'Target directory does not exist or is not a directory: %s\n' "$target_dir" >&2
  exit 66
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
project_root=$(cd "$script_dir/.." && pwd -P)
template_root="$project_root/templates/project-workflow"
target_root=$(cd "$target_dir" && pwd -P)

sources=(
  'AGENTS.template.md'
  'PROJECT_PROFILE.template.md'
  'WORKFLOW_BASELINE.yaml'
  'openSpec/config.template.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
)

destinations=(
  'AGENTS.md'
  'PROJECT_PROFILE.md'
  'WORKFLOW_BASELINE.yaml'
  'openSpec/config.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
)

directory_destinations=(
  'openSpec/changes/archive'
)

for source in "${sources[@]}"; do
  if [[ ! -f "$template_root/$source" ]]; then
    printf 'Template source is missing: %s\n' "$template_root/$source" >&2
    exit 70
  fi
done

safety_paths=()
for destination in "${destinations[@]}"; do
  relative_parent=${destination%/*}
  if [[ "$relative_parent" != "$destination" ]]; then
    safety_paths+=("$relative_parent")
  fi
done
for directory_destination in "${directory_destinations[@]}"; do
  safety_paths+=("$directory_destination")
done

unsafe_parents=()
for safety_path in "${safety_paths[@]}"; do
  relative_path=''
  IFS='/' read -r -a parent_parts <<<"$safety_path"
  for part in "${parent_parts[@]}"; do
    relative_path=${relative_path:+$relative_path/}$part
    if [[ -L "$target_root/$relative_path" || ( -e "$target_root/$relative_path" && ! -d "$target_root/$relative_path" ) ]]; then
      already_reported='false'
      if ((${#unsafe_parents[@]} > 0)); then
        for unsafe_parent in "${unsafe_parents[@]}"; do
          if [[ "$unsafe_parent" == "$relative_path" ]]; then
            already_reported='true'
            break
          fi
        done
      fi
      if [[ "$already_reported" == 'false' ]]; then
        unsafe_parents+=("$relative_path")
      fi
      break
    fi
  done
done

if ((${#unsafe_parents[@]} > 0)); then
  printf 'Installation stopped. Unsafe destination parent paths were found:\n' >&2
  for unsafe_parent in "${unsafe_parents[@]}"; do
    printf '  - %s\n' "$unsafe_parent" >&2
  done
  printf 'No files were written. Replace the links with directories or merge the workflow manually.\n' >&2
  exit 73
fi

conflicts=()
for destination in "${destinations[@]}"; do
  destination_path="$target_root/$destination"
  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    conflicts+=("$destination")
  fi
done

if ((${#conflicts[@]} > 0)); then
  printf 'Installation stopped. Existing destination files were found:\n' >&2
  for conflict in "${conflicts[@]}"; do
    printf '  - %s\n' "$conflict" >&2
  done
  printf 'No files were written. Compare and merge the existing project rules manually.\n' >&2
  exit 2
fi

printf 'Target: %s\n' "$target_root"
printf 'Planned files:\n'
for destination in "${destinations[@]}"; do
  printf '  - %s\n' "$destination"
done
for directory_destination in "${directory_destinations[@]}"; do
  printf '  - %s/ (directory)\n' "$directory_destination"
done

if [[ "$dry_run" == 'true' ]]; then
  printf 'Dry run complete. No files were written.\n'
  exit 0
fi

for index in "${!sources[@]}"; do
  source_path="$template_root/${sources[$index]}"
  destination_path="$target_root/${destinations[$index]}"
  mkdir -p "$(dirname "$destination_path")"
  cp "$source_path" "$destination_path"
done

for directory_destination in "${directory_destinations[@]}"; do
  mkdir -p "$target_root/$directory_destination"
done

printf 'Installation complete. Fill PROJECT_PROFILE.md and replace all template variables before using the workflow.\n'
