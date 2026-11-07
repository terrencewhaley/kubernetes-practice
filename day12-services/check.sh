#!/usr/bin/env bash
cd "$(dirname "$0")" && source ../lib.sh
echo "Day 12 – services"

for d in backend frontend; do
  eq "$d: replicas"       "$(jp deploy $d '{.spec.replicas}')" 2
  eq "$d: ready"          "$(jp deploy $d '{.status.readyReplicas}')" 2
  eq "$d: label app=$d"   "$(jp deploy $d '{.spec.template.metadata.labels.app}')" $d
done

S=backend-svc
eq "$S type"              "$(jp svc $S '{.spec.type}')" ClusterIP
eq "$S port"              "$(jp svc $S '{.spec.ports[0].port}')" 80
eq "$S targetPort"        "$(jp svc $S '{.spec.ports[0].targetPort}')" 80
eq "$S selector"          "$(jp svc $S '{.spec.selector.app}')" backend
eq "$S has 2 endpoints"   "$(kubectl get endpoints $S -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w | tr -d ' ')" 2

S=frontend-np
eq "$S type"              "$(jp svc $S '{.spec.type}')" NodePort
eq "$S nodePort"          "$(jp svc $S '{.spec.ports[0].nodePort}')" 30080
eq "$S selector"          "$(jp svc $S '{.spec.selector.app}')" frontend
contains "$S reachable on localhost:30080" "$(curl -s -m 5 localhost:30080)" "nginx"

S=frontend-lb
eq "$S type"              "$(jp svc $S '{.spec.type}')" LoadBalancer
eq "$S selector"          "$(jp svc $S '{.spec.selector.app}')" frontend
eq "$S port"              "$(jp svc $S '{.spec.ports[0].port}')" 80

S=ext-svc
eq "$S type"              "$(jp svc $S '{.spec.type}')" ExternalName
eq "$S externalName"      "$(jp svc $S '{.spec.externalName}')" example.com

echo "  (running in-cluster DNS test, ~10s)"
OUT=$(kubectl run dnstest-$RANDOM --rm -i --restart=Never --image=busybox:1.36 -- \
  wget -qO- -T 5 http://backend-svc 2>/dev/null)
contains "backend-svc resolves & serves by name" "$OUT" "nginx"

summary
