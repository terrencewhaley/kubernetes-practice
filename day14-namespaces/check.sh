#!/usr/bin/env bash
cd "$(dirname "$0")"
export ALLOW_NS=1   # this day changes the default namespace on purpose
source ../lib.sh
echo "Day 14 – namespaces"

eq "app1-ns exists"         "$(kubectl get ns app1-ns -o jsonpath='{.metadata.name}' 2>/dev/null)" app1-ns
eq "app2-ns exists"         "$(kubectl get ns app2-ns -o jsonpath='{.metadata.name}' 2>/dev/null)" app2-ns
eq "app2-ns label env=dev"  "$(kubectl get ns app2-ns -o jsonpath='{.metadata.labels.env}' 2>/dev/null)" dev
[[ -f app2-ns.yaml ]] && contains "app2-ns.yaml is a Namespace" "$(cat app2-ns.yaml)" "kind: Namespace" \
  || eq "app2-ns.yaml exists" missing present
[[ -f backend.yaml ]] && contains "backend.yaml sets metadata.namespace" "$(cat backend.yaml)" "namespace: app1-ns" \
  || eq "backend.yaml exists" missing present

eq "backend replicas"       "$(jpn app1-ns deploy backend '{.spec.replicas}')" 2
eq "backend ready"          "$(jpn app1-ns deploy backend '{.status.readyReplicas}')" 2
eq "backend image"          "$(jpn app1-ns deploy backend '{.spec.template.spec.containers[0].image}')" nginx:1.25
eq "backend-svc type"       "$(jpn app1-ns svc backend-svc '{.spec.type}')" ClusterIP
eq "backend-svc port"       "$(jpn app1-ns svc backend-svc '{.spec.ports[0].port}')" 9090
eq "backend-svc targetPort" "$(jpn app1-ns svc backend-svc '{.spec.ports[0].targetPort}')" 80
eq "backend-svc endpoints"  "$(kubectl get endpoints -n app1-ns backend-svc -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w | tr -d ' ')" 2

eq "frontend replicas"      "$(jpn app2-ns deploy frontend '{.spec.replicas}')" 1
eq "frontend ready"         "$(jpn app2-ns deploy frontend '{.status.readyReplicas}')" 1
eq "tester image"           "$(jpn app2-ns pod tester '{.spec.containers[0].image}')" busybox:1.36
eq "tester phase"           "$(jpn app2-ns pod tester '{.status.phase}')" Running

OUT=$(kubectl exec -n app2-ns tester -- wget -qO- -T 5 http://backend-svc.app1-ns:9090 2>/dev/null)
contains "tester reaches backend-svc.app1-ns:9090" "$OUT" "nginx"

kubectl exec -n app2-ns tester -- wget -qO- -T 5 http://backend-svc:9090 >/dev/null 2>&1
RC=$?
eq "short name does NOT cross namespaces" "$([[ $RC -ne 0 ]] && echo fails || echo works)" fails

eq "context default namespace is app1-ns" "$(kubectl config view --minify -o jsonpath='{..namespace}')" app1-ns

echo
echo "Reminder: reset with  kubectl config set-context --current --namespace=default"
summary
