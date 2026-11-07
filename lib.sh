#!/usr/bin/env bash
# Shared helpers for check.sh scripts. Source this file; don't run it directly.

# Safety: this kubeconfig also holds other clusters (docker-desktop, EKS). Only run against kind-cka.
if [[ "$(kubectl config current-context 2>/dev/null)" != "kind-cka" ]]; then
  echo "Refusing to run: current context is '$(kubectl config current-context)', not kind-cka."
  echo "Fix with: kubectl config use-context kind-cka"
  exit 2
fi

PASS=0
FAIL=0

# jp <kind> <name> <jsonpath>  -> prints the field, empty if missing
jp() { kubectl get "$1" "$2" -o jsonpath="$3" 2>/dev/null; }

# eq <description> <actual> <expected>
eq() {
  if [[ "$2" == "$3" ]]; then
    echo "  ✔ $1"; PASS=$((PASS + 1))
  else
    echo "  ✘ $1 (got: '${2}', want: '${3}')"; FAIL=$((FAIL + 1))
  fi
}

# nonempty <description> <value>
nonempty() {
  if [[ -n "$2" ]]; then
    echo "  ✔ $1"; PASS=$((PASS + 1))
  else
    echo "  ✘ $1 (empty)"; FAIL=$((FAIL + 1))
  fi
}

# contains <description> <haystack> <needle>
contains() {
  if [[ "$2" == *"$3"* ]]; then
    echo "  ✔ $1"; PASS=$((PASS + 1))
  else
    echo "  ✘ $1 (missing '${3}')"; FAIL=$((FAIL + 1))
  fi
}

summary() {
  echo
  echo "Passed: $PASS  Failed: $FAIL"
  [[ $FAIL -eq 0 ]]
}
