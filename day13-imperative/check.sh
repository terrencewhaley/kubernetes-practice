#!/usr/bin/env bash
cd "$(dirname "$0")" && source ../lib.sh
echo "Day 13 – imperative drill"

D=orders
eq "$D: replicas"       "$(jp deploy $D '{.spec.replicas}')" 3
eq "$D: ready"          "$(jp deploy $D '{.status.readyReplicas}')" 3
eq "$D: image"          "$(jp deploy $D '{.spec.template.spec.containers[0].image}')" nginx:1.25
eq "$D: containerPort"  "$(jp deploy $D '{.spec.template.spec.containers[0].ports[0].containerPort}')" 80

S=orders-svc
eq "$S type"            "$(jp svc $S '{.spec.type}')" ClusterIP
eq "$S port"            "$(jp svc $S '{.spec.ports[0].port}')" 8080
eq "$S targetPort"      "$(jp svc $S '{.spec.ports[0].targetPort}')" 80
eq "$S has 3 endpoints" "$(kubectl get endpoints $S -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w | tr -d ' ')" 3

D=store
eq "$D: replicas"       "$(jp deploy $D '{.spec.replicas}')" 2
eq "$D: ready"          "$(jp deploy $D '{.status.readyReplicas}')" 2
eq "$D: image"          "$(jp deploy $D '{.spec.template.spec.containers[0].image}')" nginx:1.25

S=store-np
eq "$S type"            "$(jp svc $S '{.spec.type}')" NodePort
eq "$S port"            "$(jp svc $S '{.spec.ports[0].port}')" 80
eq "$S targetPort"      "$(jp svc $S '{.spec.ports[0].targetPort}')" 80
eq "$S nodePort"        "$(jp svc $S '{.spec.ports[0].nodePort}')" 30090
eq "$S has 2 endpoints" "$(kubectl get endpoints $S -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w | tr -d ' ')" 2

P=probe
eq "$P image"           "$(jp pod $P '{.spec.containers[0].image}')" busybox:1.36
eq "$P restartPolicy"   "$(jp pod $P '{.spec.restartPolicy}')" Never
eq "$P label role"      "$(jp pod $P '{.metadata.labels.role}')" tester
eq "$P label team"      "$(jp pod $P '{.metadata.labels.team}')" qa
eq "$P command"         "$(jp pod $P '{.spec.containers[0].args[*]}{.spec.containers[0].command[*]}')" "sleep 3600"
eq "$P phase"           "$(jp pod $P '{.status.phase}')" Running

echo "  batch.yaml (generated, not applied)"
if [[ -f batch.yaml ]]; then
  eq "batch.yaml kind"     "$(kubectl apply --dry-run=client -f batch.yaml -o jsonpath='{.kind}' 2>/dev/null)" Deployment
  eq "batch.yaml name"     "$(kubectl apply --dry-run=client -f batch.yaml -o jsonpath='{.metadata.name}' 2>/dev/null)" batch
  eq "batch.yaml replicas" "$(kubectl apply --dry-run=client -f batch.yaml -o jsonpath='{.spec.replicas}' 2>/dev/null)" 1
  eq "batch.yaml image"    "$(kubectl apply --dry-run=client -f batch.yaml -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)" nginx:1.25
else
  eq "batch.yaml exists" missing present
fi
eq "batch NOT applied"  "$(kubectl get deploy batch -o name 2>/dev/null)" ""

echo "  (running in-cluster test, ~10s)"
OUT=$(kubectl run curltest-$RANDOM --rm -i --restart=Never --image=busybox:1.36 -- \
  wget -qO- -T 5 http://orders-svc:8080 2>/dev/null)
contains "orders-svc:8080 serves nginx" "$OUT" "nginx"

summary
