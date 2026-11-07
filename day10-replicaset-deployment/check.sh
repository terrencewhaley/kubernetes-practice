#!/usr/bin/env bash
cd "$(dirname "$0")" && source ../lib.sh

echo "Day 10A – api-rs"
R=api-rs
eq "replicas"            "$(jp rs $R '{.spec.replicas}')" 3
eq "ready replicas"      "$(jp rs $R '{.status.readyReplicas}')" 3
eq "selector operators"  "$(jp rs $R '{.spec.selector.matchExpressions[*].operator}')" "In Exists"
eq "no matchLabels"      "$(jp rs $R '{.spec.selector.matchLabels}')" ""
eq "In values"           "$(jp rs $R '{.spec.selector.matchExpressions[?(@.key=="app")].values[*]}')" api
eq "template labels"     "$(jp rs $R '{.spec.template.metadata.labels.app}-{.spec.template.metadata.labels.env}')" api-prod
eq "image"               "$(jp rs $R '{.spec.template.spec.containers[0].image}')" nginx:1.24

echo "Day 10B – shop-deploy"
D=shop-deploy
eq "replicas"            "$(jp deploy $D '{.spec.replicas}')" 4
eq "ready replicas"      "$(jp deploy $D '{.status.readyReplicas}')" 4
eq "strategy type"       "$(jp deploy $D '{.spec.strategy.type}')" RollingUpdate
eq "maxSurge"            "$(jp deploy $D '{.spec.strategy.rollingUpdate.maxSurge}')" 1
eq "maxUnavailable"      "$(jp deploy $D '{.spec.strategy.rollingUpdate.maxUnavailable}')" 0
eq "rolled back to 1.24" "$(jp deploy $D '{.spec.template.spec.containers[0].image}')" nginx:1.24
nonempty "change-cause set" "$(jp deploy $D '{.metadata.annotations.kubernetes\.io/change-cause}')"
REVS=$(kubectl rollout history deploy/$D 2>/dev/null | grep -cE '^[0-9]+')
[[ "$REVS" -ge 2 ]] && eq "history has >=2 revisions" ok ok || eq "history has >=2 revisions" "$REVS" ">=2"
# undo --to-revision=1 consumes revision 1 and creates a new one, so the newest revision is 3
eq "latest revision is 3" "$(jp deploy $D '{.metadata.annotations.deployment\.kubernetes\.io/revision}')" 3

summary
