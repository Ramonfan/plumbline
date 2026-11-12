#!/usr/bin/env bash

set -euo pipefail

for required_command in bash find rg ruby openspec; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$required_command" >&2
    exit 69
  fi
done

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
project_root=$(cd "$script_dir/.." && pwd -P)
template_root="$project_root/templates/project-workflow"

required_project_files=(
  'AGENTS.md'
  'PROJECT_PROFILE.md'
  'README.md'
  'CHANGELOG.md'
  'openSpec/config.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'openSpec/specs/portable-project-workflow/spec.md'
  'scripts/install.sh'
  'scripts/verify.sh'
)

required_template_files=(
  'AGENTS.template.md'
  'PROJECT_PROFILE.template.md'
  'WORKFLOW_BASELINE.yaml'
  'INSTALL.md'
  'openSpec/config.template.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
  'examples/ios/PROJECT_PROFILE.example.md'
  'examples/coding-behavior-guidelines.md'
)

for relative_path in "${required_project_files[@]}"; do
  test -s "$project_root/$relative_path"
done

for relative_path in "${required_template_files[@]}"; do
  test -s "$template_root/$relative_path"
done

bash -n "$project_root/scripts/install.sh" "$project_root/scripts/verify.sh"

ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); YAML.load_file(ARGV.fetch(1)); baseline = YAML.load_file(ARGV.fetch(2)); abort("Invalid baseline schema_version") unless baseline["schema_version"] == 1; abort("Invalid workflow_version") unless baseline["workflow_version"] == "0.1.0-dev.2"; abort("Invalid authority_name") unless baseline["authority_name"] == "AI 工作流"' \
  "$project_root/openSpec/config.yaml" \
  "$template_root/openSpec/config.template.yaml" \
  "$template_root/WORKFLOW_BASELINE.yaml"

ruby -e 'Dir.glob(File.join(ARGV.fetch(0), "**", "*.md")).each { |file| count = File.readlines(file).count { |line| line.start_with?("```") }; abort("Unclosed Markdown fence: #{file}") if count.odd? }' \
  "$project_root"

placeholder_files=$(rg -l '\{\{[A-Z0-9_]+\}\}' "$template_root" | sort)
expected_placeholder_files=$(printf '%s\n' \
  "$template_root/AGENTS.template.md" \
  "$template_root/PROJECT_PROFILE.template.md" \
  "$template_root/openSpec/config.template.yaml" | sort)

if [[ "$placeholder_files" != "$expected_placeholder_files" ]]; then
  printf 'Unexpected template variable scope.\nExpected:\n%s\nActual:\n%s\n' \
    "$expected_placeholder_files" "$placeholder_files" >&2
  exit 1
fi

if rg -n 'NNIM|NNLightWeb|JXPaging|PUBG|战力|荣耀勋章|荣誉勋章|语音房|社区房间|App改造|nnios' "$template_root"; then
  printf 'Business-specific content leaked into the reusable template.\n' >&2
  exit 1
fi

core_files=(
  "$template_root/AGENTS.template.md"
  "$template_root/PROJECT_PROFILE.template.md"
  "$template_root/openSpec/config.template.yaml"
  "$template_root/openSpec/README.md"
  "$template_root/openSpec/specs/development-workflow/spec.md"
  "$template_root/openSpec/weekly_report_template.md"
  "$template_root/superPowers/implementation_checklist.md"
)

if rg -n 'CocoaPods|iphoneos|UIKit|Swift|Objective-C|Xcode|Podfile|podspec' "${core_files[@]}"; then
  printf 'Technology-specific content leaked outside the examples directory.\n' >&2
  exit 1
fi

tmp_base=${TMPDIR:-/tmp}
if [[ ! -d "$tmp_base" || ! -w "$tmp_base" || ! -x "$tmp_base" ]]; then
  printf 'Temporary directory is missing, not writable, or not searchable: %s\n' "$tmp_base" >&2
  exit 73
fi
if ! tmp_base=$(cd "$tmp_base" && pwd -P); then
  printf 'Unable to resolve temporary directory: %s\n' "$tmp_base" >&2
  exit 73
fi
if ! tmp_root=$(mktemp -d "$tmp_base/ai-workflow-verify.XXXXXX"); then
  printf 'Unable to create verification directory under: %s\n' "$tmp_base" >&2
  exit 73
fi
cleanup() {
  case "$tmp_root" in
    "$tmp_base"/ai-workflow-verify.*)
      if [[ -d "$tmp_root" ]]; then
        rm -rf -- "$tmp_root"
      fi
      ;;
  esac
}
trap cleanup EXIT

snapshot_tree() {
  local root=$1
  (
    cd "$root"
    find . -mindepth 1 -print | LC_ALL=C sort | while IFS= read -r path; do
      if [[ -L "$path" ]]; then
        printf 'L %s -> %s\n' "$path" "$(readlink "$path")"
      elif [[ -d "$path" ]]; then
        printf 'D %s\n' "$path"
      elif [[ -f "$path" ]]; then
        printf 'F %s ' "$path"
        cksum "$path"
      else
        printf 'O %s\n' "$path"
      fi
    done
  )
}

template_sources=(
  'AGENTS.template.md'
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
  'PROJECT_PROFILE.md'
  'WORKFLOW_BASELINE.yaml'
  'openSpec/config.yaml'
  'openSpec/README.md'
  'openSpec/weekly_report_template.md'
  'openSpec/specs/development-workflow/spec.md'
  'superPowers/implementation_checklist.md'
)

dry_target="$tmp_root/dry-target"
install_target="$tmp_root/install-target"
partial_target="$tmp_root/partial-target"
symlink_target="$tmp_root/symlink-target"
symlink_external="$tmp_root/symlink-external"
blocked_parent_target="$tmp_root/blocked-parent-target"
mkdir -p "$dry_target" "$install_target" "$partial_target/openSpec" "$symlink_target" "$symlink_external" "$blocked_parent_target"

dry_output=$("$project_root/scripts/install.sh" --target "$dry_target" --dry-run)
if find "$dry_target" -mindepth 1 -print -quit | grep -q .; then
  printf 'Dry run wrote files unexpectedly.\n' >&2
  exit 1
fi
actual_planned=$(printf '%s\n' "$dry_output" | rg '^  - ')
expected_planned=$(printf '  - %s\n' "${installed_destinations[@]}" 'openSpec/changes/archive/ (directory)')
if [[ "$actual_planned" != "$expected_planned" ]]; then
  printf 'Dry run plan did not match the exact install mapping.\nExpected:\n%s\nActual:\n%s\n' \
    "$expected_planned" "$actual_planned" >&2
  exit 1
fi

"$project_root/scripts/install.sh" --target "$install_target" >/dev/null
for index in "${!template_sources[@]}"; do
  source_path="$template_root/${template_sources[$index]}"
  destination_path="$install_target/${installed_destinations[$index]}"
  test -s "$destination_path"
  cmp "$source_path" "$destination_path"
done
test -d "$install_target/openSpec/changes/archive"
actual_install_tree=$(
  cd "$install_target"
  find . -mindepth 1 -print | LC_ALL=C sort
)
expected_install_tree=$(printf '%s\n' \
  './AGENTS.md' \
  './PROJECT_PROFILE.md' \
  './WORKFLOW_BASELINE.yaml' \
  './openSpec' \
  './openSpec/README.md' \
  './openSpec/changes' \
  './openSpec/changes/archive' \
  './openSpec/config.yaml' \
  './openSpec/specs' \
  './openSpec/specs/development-workflow' \
  './openSpec/specs/development-workflow/spec.md' \
  './openSpec/weekly_report_template.md' \
  './superPowers' \
  './superPowers/implementation_checklist.md' | LC_ALL=C sort)
if [[ "$actual_install_tree" != "$expected_install_tree" ]]; then
  printf 'Installed tree did not match the exact expected mapping.\nExpected:\n%s\nActual:\n%s\n' \
    "$expected_install_tree" "$actual_install_tree" >&2
  exit 1
fi

printf 'existing AGENTS\n' >"$partial_target/AGENTS.md"
printf 'existing config\n' >"$partial_target/openSpec/config.yaml"
before_partial=$(snapshot_tree "$partial_target")
set +e
"$project_root/scripts/install.sh" --target "$partial_target" >"$tmp_root/partial.out" 2>"$tmp_root/partial.err"
partial_status=$?
set -e
if [[ $partial_status -ne 2 ]]; then
  printf 'Partial conflict installation returned %s instead of 2.\n' "$partial_status" >&2
  exit 1
fi
for conflict in AGENTS.md openSpec/config.yaml; do
  if ! rg -F -q "  - $conflict" "$tmp_root/partial.err"; then
    printf 'Partial conflict output omitted: %s\n' "$conflict" >&2
    exit 1
  fi
done
after_partial=$(snapshot_tree "$partial_target")
if [[ "$before_partial" != "$after_partial" ]]; then
  printf 'Partial conflict installation changed the target tree.\n' >&2
  exit 1
fi

before_repeat=$(snapshot_tree "$install_target")
set +e
"$project_root/scripts/install.sh" --target "$install_target" >"$tmp_root/repeat.out" 2>"$tmp_root/repeat.err"
repeat_status=$?
set -e
if [[ $repeat_status -ne 2 ]]; then
  printf 'Repeat installation returned %s instead of 2.\n' "$repeat_status" >&2
  exit 1
fi
for conflict in "${installed_destinations[@]}"; do
  if ! rg -F -q "  - $conflict" "$tmp_root/repeat.err"; then
    printf 'Repeat installation output omitted: %s\n' "$conflict" >&2
    exit 1
  fi
done
after_repeat=$(snapshot_tree "$install_target")
if [[ "$before_repeat" != "$after_repeat" ]]; then
  printf 'Repeat installation changed the target tree.\n' >&2
  exit 1
fi

ln -s "$symlink_external" "$symlink_target/openSpec"
before_symlink_target=$(snapshot_tree "$symlink_target")
before_symlink_external=$(snapshot_tree "$symlink_external")
set +e
"$project_root/scripts/install.sh" --target "$symlink_target" >"$tmp_root/symlink.out" 2>"$tmp_root/symlink.err"
symlink_status=$?
set -e
if [[ $symlink_status -ne 73 ]]; then
  printf 'Symlink parent installation returned %s instead of 73.\n' "$symlink_status" >&2
  exit 1
fi
if ! rg -F -q '  - openSpec' "$tmp_root/symlink.err"; then
  printf 'Symlink parent output omitted: openSpec\n' >&2
  exit 1
fi
after_symlink_target=$(snapshot_tree "$symlink_target")
after_symlink_external=$(snapshot_tree "$symlink_external")
if [[ "$before_symlink_target" != "$after_symlink_target" || "$before_symlink_external" != "$after_symlink_external" ]]; then
  printf 'Symlink parent installation changed the target or external tree.\n' >&2
  exit 1
fi

printf 'not a directory\n' >"$blocked_parent_target/openSpec"
before_blocked_parent=$(snapshot_tree "$blocked_parent_target")
set +e
"$project_root/scripts/install.sh" --target "$blocked_parent_target" >"$tmp_root/blocked-parent.out" 2>"$tmp_root/blocked-parent.err"
blocked_parent_status=$?
set -e
if [[ $blocked_parent_status -ne 73 ]]; then
  printf 'Non-directory parent installation returned %s instead of 73.\n' "$blocked_parent_status" >&2
  exit 1
fi
if ! rg -F -q '  - openSpec' "$tmp_root/blocked-parent.err"; then
  printf 'Non-directory parent output omitted: openSpec\n' >&2
  exit 1
fi
after_blocked_parent=$(snapshot_tree "$blocked_parent_target")
if [[ "$before_blocked_parent" != "$after_blocked_parent" ]]; then
  printf 'Non-directory parent installation changed the target tree.\n' >&2
  exit 1
fi

assert_unsafe_install_rejected() {
  local label=$1
  local target=$2
  local expected_path=$3
  local external_root=${4:-}
  local before_target
  local before_external=''
  local status
  local after_target
  local after_external=''

  before_target=$(snapshot_tree "$target")
  if [[ -n "$external_root" ]]; then
    before_external=$(snapshot_tree "$external_root")
  fi

  set +e
  "$project_root/scripts/install.sh" --target "$target" >"$tmp_root/$label.out" 2>"$tmp_root/$label.err"
  status=$?
  set -e

  if [[ $status -ne 73 ]]; then
    printf '%s installation returned %s instead of 73.\n' "$label" "$status" >&2
    exit 1
  fi
  if ! rg -F -q "  - $expected_path" "$tmp_root/$label.err"; then
    printf '%s output omitted: %s\n' "$label" "$expected_path" >&2
    exit 1
  fi

  after_target=$(snapshot_tree "$target")
  if [[ -n "$external_root" ]]; then
    after_external=$(snapshot_tree "$external_root")
  fi
  if [[ "$before_target" != "$after_target" || "$before_external" != "$after_external" ]]; then
    printf '%s installation changed the target or external tree.\n' "$label" >&2
    exit 1
  fi
}

nested_changes_link_target="$tmp_root/nested-changes-link-target"
nested_changes_link_external="$tmp_root/nested-changes-link-external"
mkdir -p "$nested_changes_link_target/openSpec" "$nested_changes_link_external"
ln -s "$nested_changes_link_external" "$nested_changes_link_target/openSpec/changes"
assert_unsafe_install_rejected 'nested-changes-link' "$nested_changes_link_target" 'openSpec/changes' "$nested_changes_link_external"

nested_archive_link_target="$tmp_root/nested-archive-link-target"
nested_archive_link_external="$tmp_root/nested-archive-link-external"
mkdir -p "$nested_archive_link_target/openSpec/changes" "$nested_archive_link_external"
ln -s "$nested_archive_link_external" "$nested_archive_link_target/openSpec/changes/archive"
assert_unsafe_install_rejected 'nested-archive-link' "$nested_archive_link_target" 'openSpec/changes/archive' "$nested_archive_link_external"

nested_changes_file_target="$tmp_root/nested-changes-file-target"
mkdir -p "$nested_changes_file_target/openSpec"
printf 'not a directory\n' >"$nested_changes_file_target/openSpec/changes"
assert_unsafe_install_rejected 'nested-changes-file' "$nested_changes_file_target" 'openSpec/changes'

nested_archive_file_target="$tmp_root/nested-archive-file-target"
mkdir -p "$nested_archive_file_target/openSpec/changes"
printf 'not a directory\n' >"$nested_archive_file_target/openSpec/changes/archive"
assert_unsafe_install_rejected 'nested-archive-file' "$nested_archive_file_target" 'openSpec/changes/archive'

(
  cd "$project_root"
  openspec context >/dev/null
  openspec doctor >/dev/null
  openspec validate development-workflow --type spec --strict >/dev/null
  openspec validate portable-project-workflow --type spec --strict >/dev/null
)

printf 'ALL_CHECKS_PASSED\n'
