#!/usr/bin/env bash

set -euo pipefail

for required_command in bash find rg ruby openspec sort cksum cmp readlink ln mktemp; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$required_command" >&2
    exit 69
  fi
done

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
project_root=$(cd "$script_dir/.." && pwd -P)
template_root="$project_root/templates/project-workflow"

source "$script_dir/workflow-files.sh"

required_project_files=(
  'AGENTS.md'
  'CLAUDE.md'
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
  'scripts/compare.sh'
  'scripts/workflow-files.sh'
)

required_template_files=(
  'AGENTS.template.md'
  'CLAUDE.template.md'
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

bash -n "$project_root/scripts/install.sh" "$project_root/scripts/verify.sh" "$project_root/scripts/compare.sh" "$project_root/scripts/workflow-files.sh"

ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); YAML.load_file(ARGV.fetch(1)); baseline = YAML.load_file(ARGV.fetch(2)); abort("Invalid baseline schema_version") unless baseline["schema_version"] == 1; abort("Invalid workflow_version") unless baseline["workflow_version"] == "0.1.0-dev.4"; abort("Invalid authority_name") unless baseline["authority_name"] == "Plumbline"' \
  "$project_root/openSpec/config.yaml" \
  "$template_root/openSpec/config.template.yaml" \
  "$template_root/WORKFLOW_BASELINE.yaml"

identity_files=(
  "$project_root/AGENTS.md"
  "$project_root/PROJECT_PROFILE.md"
  "$project_root/README.md"
  "$project_root/openSpec/config.yaml"
  "$project_root/openSpec/README.md"
  "$template_root/INSTALL.md"
)

for identity_file in "${identity_files[@]}"; do
  if ! rg -F -q 'Plumbline' "$identity_file"; then
    printf 'Project identity file does not use the official name: %s\n' "$identity_file" >&2
    exit 1
  fi
done

if rg -n -F 'AI 工作流' "${identity_files[@]}"; then
  printf 'Stale project name remains in an identity file.\n' >&2
  exit 1
fi

ruby -e '
  files = Dir.glob(File.join(ARGV.fetch(0), "**", "*.md"), File::FNM_DOTMATCH)
  files.reject! { |file| file.include?("/.git/") }
  files.each { |file| count = File.readlines(file).count { |line| line.start_with?("```") }; abort("Unclosed Markdown fence: #{file}") if count.odd? }
' "$project_root"

placeholder_files=$(rg -l --hidden --glob '!**/.git/**' '\{\{[A-Z0-9_]+\}\}' "$template_root" | sort || true)
expected_placeholder_files=$(printf '%s\n' \
  "$template_root/AGENTS.template.md" \
  "$template_root/PROJECT_PROFILE.template.md" \
  "$template_root/openSpec/config.template.yaml" | sort)

if [[ "$placeholder_files" != "$expected_placeholder_files" ]]; then
  printf 'Unexpected template variable scope.\nExpected:\n%s\nActual:\n%s\n' \
    "$expected_placeholder_files" "$placeholder_files" >&2
  exit 1
fi

if rg -n --hidden --glob '!**/.git/**' 'NNIM|NNLightWeb|JXPaging|PUBG|战力|荣耀勋章|荣誉勋章|语音房|社区房间|App改造|nnios' "$template_root"; then
  printf 'Business-specific content leaked into the reusable template.\n' >&2
  exit 1
fi

core_files=(
  "$template_root/AGENTS.template.md"
  "$template_root/CLAUDE.template.md"
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

ruby -e '
  def check_imports(path, expected)
    fence = nil
    found = Hash.new(0)
    File.readlines(path, chomp: true).each do |line|
      if fence
        fence = nil if line.start_with?(fence)
        next
      end
      if line.start_with?("```") || line.start_with?("~~~")
        fence = line.start_with?("```") ? "```" : "~~~"
        next
      end
      next if line.start_with?("    ") || line.start_with?("\t")
      found[line] += 1 if expected.key?(line)
    end
    expected.each_key do |line|
      abort("Expected exactly one column-0 #{line} import in #{path}") unless found[line] == 1
    end
  end
  imports = { "@AGENTS.md" => true, "@PROJECT_PROFILE.md" => true }
  check_imports(ARGV.fetch(0), imports)
  check_imports(ARGV.fetch(1), imports)
' "$project_root/CLAUDE.md" "$template_root/CLAUDE.template.md"

if ! cmp -s "$project_root/CLAUDE.md" "$template_root/CLAUDE.template.md"; then
  printf 'Root CLAUDE.md and template CLAUDE.template.md differ.\n' >&2
  exit 1
fi

ruby -e '
  def headings(path)
    File.readlines(path, chomp: true).grep(/^[#]{2,3} /)
  end
  def body_lines(path)
    File.readlines(path, chomp: true).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
  end
  abort("CLAUDE template is too large for a thin entry") if File.readlines(ARGV.fetch(1)).length > 60
  duplicated = headings(ARGV.fetch(0)) & headings(ARGV.fetch(1))
  abort("CLAUDE template duplicates AGENTS headings: #{duplicated.join(", ")}") unless duplicated.empty?
  duplicated_body = body_lines(ARGV.fetch(0)) & body_lines(ARGV.fetch(1))
  abort("CLAUDE template copies AGENTS body lines: #{duplicated_body.join(" | ")}") unless duplicated_body.empty?
' "$template_root/AGENTS.template.md" "$template_root/CLAUDE.template.md"

tmp_base=${TMPDIR:-/tmp}
if [[ ! -d "$tmp_base" || ! -w "$tmp_base" || ! -x "$tmp_base" ]]; then
  printf 'Temporary directory is missing, not writable, or not searchable: %s\n' "$tmp_base" >&2
  exit 73
fi
if ! tmp_base=$(cd "$tmp_base" && pwd -P); then
  printf 'Unable to resolve temporary directory: %s\n' "$tmp_base" >&2
  exit 73
fi
if ! tmp_root=$(mktemp -d "$tmp_base/plumbline-verify.XXXXXX"); then
  printf 'Unable to create verification directory under: %s\n' "$tmp_base" >&2
  exit 73
fi
cleanup() {
  case "$tmp_root" in
    "$tmp_base"/plumbline-verify.*)
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

dry_target="$tmp_root/dry-target"
install_target="$tmp_root/install-target"
partial_target="$tmp_root/partial-target"
claude_only_target="$tmp_root/claude-only-target"
symlink_target="$tmp_root/symlink-target"
symlink_external="$tmp_root/symlink-external"
blocked_parent_target="$tmp_root/blocked-parent-target"
mkdir -p "$dry_target" "$install_target" "$partial_target/openSpec" "$claude_only_target" "$symlink_target" "$symlink_external" "$blocked_parent_target"

dry_output=$("$project_root/scripts/install.sh" --target "$dry_target" --dry-run)
if [[ -n "$(find "$dry_target" -mindepth 1 -print -quit)" ]]; then
  printf 'Dry run wrote files unexpectedly.\n' >&2
  exit 1
fi
actual_planned=$(printf '%s\n' "$dry_output" | rg '^  - ' || true)
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
  './CLAUDE.md' \
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
printf 'existing CLAUDE\n' >"$partial_target/CLAUDE.md"
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
for conflict in AGENTS.md CLAUDE.md openSpec/config.yaml; do
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

printf 'existing CLAUDE only\n' >"$claude_only_target/CLAUDE.md"
before_claude_only=$(snapshot_tree "$claude_only_target")
set +e
"$project_root/scripts/install.sh" --target "$claude_only_target" >"$tmp_root/claude-only.out" 2>"$tmp_root/claude-only.err"
claude_only_status=$?
set -e
if [[ $claude_only_status -ne 2 ]]; then
  printf 'CLAUDE-only conflict installation returned %s instead of 2.\n' "$claude_only_status" >&2
  exit 1
fi
if ! rg -F -q '  - CLAUDE.md' "$tmp_root/claude-only.err"; then
  printf 'CLAUDE-only conflict output omitted: CLAUDE.md\n' >&2
  exit 1
fi
after_claude_only=$(snapshot_tree "$claude_only_target")
if [[ "$before_claude_only" != "$after_claude_only" ]]; then
  printf 'CLAUDE-only conflict installation changed the target tree.\n' >&2
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

compare_base="$tmp_root/base-snapshot"
cp -R "$template_root" "$compare_base"

run_compare() {
  local label=$1
  local target=$2
  local base=${3:-}
  local before_target
  local before_base=''
  local before_template
  local after_target
  local after_base=''
  local after_template
  local output

  before_target=$(snapshot_tree "$target")
  before_template=$(snapshot_tree "$template_root")
  if [[ -n "$base" ]]; then
    before_base=$(snapshot_tree "$base")
  fi

  if [[ -n "$base" ]]; then
    output=$("$project_root/scripts/compare.sh" --target "$target" --base "$base")
  else
    output=$("$project_root/scripts/compare.sh" --target "$target")
  fi

  after_target=$(snapshot_tree "$target")
  after_template=$(snapshot_tree "$template_root")
  if [[ -n "$base" ]]; then
    after_base=$(snapshot_tree "$base")
  fi
  if [[ "$before_target" != "$after_target" || "$before_base" != "$after_base" || "$before_template" != "$after_template" ]]; then
    printf '%s comparison changed the target, base, or template tree.\n' "$label" >&2
    exit 1
  fi
  printf '%s\n' "$output"
}

assert_compare_status() {
  local output=$1
  local status=$2
  local file=$3
  local prefix
  prefix=$(printf '%-14s %-48s' "$status" "$file")
  if ! printf '%s\n' "$output" | rg -F -q "$prefix"; then
    printf 'Comparison did not report %s for %s.\n' "$status" "$file" >&2
    exit 1
  fi
}

identical_output=$(run_compare 'identical' "$install_target")
for destination in "${installed_destinations[@]}"; do
  assert_compare_status "$identical_output" 'unchanged' "$destination"
done
assert_compare_status "$identical_output" 'unchanged' 'openSpec/changes/archive/'
if ! printf '%s\n' "$identical_output" | rg -F -q 'manual: project-specific'; then
  printf 'Comparison omitted the project-specific manual note.\n' >&2
  exit 1
fi
if ! printf '%s\n' "$identical_output" | rg -F -q 'metadata: update after merge'; then
  printf 'Comparison omitted the baseline metadata note.\n' >&2
  exit 1
fi

ours_target="$tmp_root/ours-target"
cp -R "$install_target" "$ours_target"
printf '\nlocal rule\n' >>"$ours_target/AGENTS.md"
ours_output=$(run_compare 'ours-only' "$ours_target" "$compare_base")
assert_compare_status "$ours_output" 'ours-only' 'AGENTS.md'
assert_compare_status "$ours_output" 'unchanged' 'openSpec/README.md'

differs_output=$(run_compare 'two-way' "$ours_target")
assert_compare_status "$differs_output" 'differs' 'AGENTS.md'
if ! printf '%s\n' "$differs_output" | rg -F -q 'two-way comparison'; then
  printf 'Two-way comparison omitted its limitation notice.\n' >&2
  exit 1
fi

theirs_target="$tmp_root/theirs-target"
theirs_base="$tmp_root/theirs-base"
cp -R "$install_target" "$theirs_target"
cp -R "$template_root" "$theirs_base"
printf '\nold template rule\n' >>"$theirs_base/AGENTS.template.md"
cp "$theirs_base/AGENTS.template.md" "$theirs_target/AGENTS.md"
theirs_output=$(run_compare 'theirs-only' "$theirs_target" "$theirs_base")
assert_compare_status "$theirs_output" 'theirs-only' 'AGENTS.md'

both_target="$tmp_root/both-target"
both_base="$tmp_root/both-base"
cp -R "$install_target" "$both_target"
cp -R "$template_root" "$both_base"
printf '\nlocal rule\n' >>"$both_target/AGENTS.md"
printf '\ntemplate rule\n' >>"$both_base/AGENTS.template.md"
both_output=$(run_compare 'both-changed' "$both_target" "$both_base")
assert_compare_status "$both_output" 'both-changed' 'AGENTS.md'

converged_target="$tmp_root/converged-target"
converged_base="$tmp_root/converged-base"
cp -R "$install_target" "$converged_target"
cp -R "$template_root" "$converged_base"
printf '\nold template rule\n' >>"$converged_base/AGENTS.template.md"
converged_output=$(run_compare 'converged' "$converged_target" "$converged_base")
assert_compare_status "$converged_output" 'converged' 'AGENTS.md'

missing_target="$tmp_root/missing-target"
cp -R "$install_target" "$missing_target"
rm "$missing_target/openSpec/README.md"
missing_output=$(run_compare 'missing' "$missing_target" "$compare_base")
assert_compare_status "$missing_output" 'missing' 'openSpec/README.md'

base_missing_target="$tmp_root/base-missing-target"
base_missing_base="$tmp_root/base-missing-base"
cp -R "$install_target" "$base_missing_target"
cp -R "$template_root" "$base_missing_base"
rm "$base_missing_base/openSpec/README.md"
base_missing_output=$(run_compare 'base-missing' "$base_missing_target" "$base_missing_base")
assert_compare_status "$base_missing_output" 'base-missing' 'openSpec/README.md'

if ! printf '%s\n' "$theirs_output" | rg -F -q 'Base baseline: '; then
  printf 'Comparison omitted the base baseline line.\n' >&2
  exit 1
fi
if ! printf '%s\n' "$theirs_output" | rg -F -q 'Template baseline: 0.1.0-dev.4'; then
  printf 'Comparison omitted the template baseline line.\n' >&2
  exit 1
fi

invalid_path_target="$tmp_root/invalid-path-target"
cp -R "$install_target" "$invalid_path_target"
rm "$invalid_path_target/openSpec/README.md"
mkdir "$invalid_path_target/openSpec/README.md"

set +e
"$project_root/scripts/compare.sh" --target "$tmp_root/does-not-exist" >/dev/null 2>&1
invalid_compare_target=$?
"$project_root/scripts/compare.sh" --target "$install_target" --base "$tmp_root/does-not-exist" >/dev/null 2>&1
invalid_compare_base=$?
"$project_root/scripts/compare.sh" --target "$install_target" --base '' >/dev/null 2>&1
invalid_compare_empty_base=$?
"$project_root/scripts/compare.sh" --target "$invalid_path_target" >/dev/null 2>&1
invalid_compare_path=$?
"$project_root/scripts/compare.sh" --unknown >/dev/null 2>&1
invalid_compare_arg=$?
set -e
if [[ $invalid_compare_target -ne 66 || $invalid_compare_base -ne 66 || $invalid_compare_empty_base -ne 64 || $invalid_compare_path -ne 66 || $invalid_compare_arg -ne 64 ]]; then
  printf 'Comparison invalid-argument statuses were %s, %s, %s, %s, %s; expected 66, 66, 64, 66, 64.\n' \
    "$invalid_compare_target" "$invalid_compare_base" "$invalid_compare_empty_base" "$invalid_compare_path" "$invalid_compare_arg" >&2
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
