#!/bin/bash
set -eo pipefail

###
# Run operator-sdk generate commands appropriate to the version of
# operator-sdk configured in the consuming repository.
###

REPO_ROOT=$(git rev-parse --show-toplevel)

source $REPO_ROOT/boilerplate/_lib/common.sh

# There's nothing to generate if pkg/apis is empty (other than apis.go).
# And instead of succeeding gracefully, `operator-sdk generate` will
# fail if you try. So do our own check.
if ! /bin/ls -1 pkg/apis | grep -Fqv apis.go; then
    echo "No APIs! Skipping operator-sdk generate."
    exit 0
fi

$HERE/ensure.sh operator-sdk

# Symlink to operator-sdk binary set up by `ensure.sh operator-sdk`:
OSDK=$REPO_ROOT/.operator-sdk/bin/operator-sdk

VER=$(osdk_version $OSDK)

# This explicitly lists the versions we know about. We don't support
# anything outside of that.
case $VER in
  'v0.15.1'|'v0.16.0'|'v0.17.0'|'v0.17.1')
      $OSDK generate crds
      $OSDK generate k8s
      ;;
  *) err "Unsupported operator-sdk version $VER" ;;
esac