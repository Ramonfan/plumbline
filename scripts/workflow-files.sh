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

installed_directories=(
  'openSpec/changes/archive'
)
