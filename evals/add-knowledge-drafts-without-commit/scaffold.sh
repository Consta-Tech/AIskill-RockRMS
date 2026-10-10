#!/usr/bin/env bash
# Runs in the empty eval workspace (only with --scaffold). Clones this plugin checkout into
# ./AIskill-RockRMS so the rockrms-add-knowledge skill has a repo to work in without network access.
set -euo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF_DIR/../.." && pwd)"
git clone -q "$REPO" AIskill-RockRMS
