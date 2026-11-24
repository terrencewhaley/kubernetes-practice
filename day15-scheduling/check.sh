#!/usr/bin/env bash
cd "$(dirname "$0")" && source ../lib.sh
echo "Day 15 – scheduling"

W1=cka-worker; W2=cka-worker2

eq "pinned image"        "$(jp pod pinned '{.spec.containers[0].image}')" nginx:1.25
eq "pinned uses nodeName" "$(jp pod pinned '{.spec.nodeName}')" $W2
[[ -f pinned.yaml ]] && contains "pinned.yaml sets nodeName" "$(cat pinned.yaml)" "nodeName:" \
  || eq "pinned.yaml exists" missing present
eq "pinned running"      "$(jp pod pinned '{.status.phase}')" Running

eq "$W1 label disk=ssd"  "$(jp node $W1 '{.metadata.labels.disk}')" ssd
eq "$W2 label pool=ml"   "$(jp node $W2 '{.metadata.labels.pool}')" ml

eq "ssd-pod nodeSelector" "$(jp pod ssd-pod '{.spec.nodeSelector.disk}')" ssd
eq "ssd-pod node"         "$(jp pod ssd-pod '{.spec.nodeName}')" $W1
eq "ssd-pod running"      "$(jp pod ssd-pod '{.status.phase}')" Running

TAINT=$(jp node $W2 '{.spec.taints[?(@.key=="dedicated")].value}:{.spec.taints[?(@.key=="dedicated")].effect}')
eq "$W2 taint dedicated=ml:NoSchedule" "$TAINT" "ml:NoSchedule"

eq "plain replicas"      "$(jp deploy plain '{.spec.replicas}')" 4
eq "plain ready"         "$(jp deploy plain '{.status.readyReplicas}')" 4
eq "plain image"         "$(jp deploy plain '{.spec.template.spec.containers[0].image}')" nginx:1.25
ON_W2=$(kubectl get pods -l app=plain -o jsonpath='{.items[*].spec.nodeName}' 2>/dev/null | tr ' ' '\n' | grep -c "^$W2$")
eq "no plain pods on $W2" "$ON_W2" 0

eq "ml-pod toleration key"    "$(jp pod ml-pod '{.spec.tolerations[?(@.key=="dedicated")].value}')" ml
eq "ml-pod nodeSelector"      "$(jp pod ml-pod '{.spec.nodeSelector.pool}')" ml
eq "ml-pod node"              "$(jp pod ml-pod '{.spec.nodeName}')" $W2
eq "ml-pod running"           "$(jp pod ml-pod '{.status.phase}')" Running

echo
echo "Reminder: remove the taint and labels (see exercise.md) when done."
summary
