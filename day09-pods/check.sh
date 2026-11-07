#!/usr/bin/env bash
cd "$(dirname "$0")" && source ../lib.sh
echo "Day 9 – web-pod"

P=web-pod
eq "labels app=web"            "$(jp pod $P '{.metadata.labels.app}')" web
eq "labels tier=frontend"      "$(jp pod $P '{.metadata.labels.tier}')" frontend
eq "container names"           "$(jp pod $P '{.spec.containers[*].name}')" "web logger"
eq "web image"                 "$(jp pod $P '{.spec.containers[0].image}')" nginx:1.25
eq "web containerPort"         "$(jp pod $P '{.spec.containers[0].ports[0].containerPort}')" 80
eq "env APP_ENV"               "$(jp pod $P '{.spec.containers[0].env[?(@.name=="APP_ENV")].value}')" dev
eq "requests.cpu"              "$(jp pod $P '{.spec.containers[0].resources.requests.cpu}')" 100m
eq "requests.memory"           "$(jp pod $P '{.spec.containers[0].resources.requests.memory}')" 64Mi
eq "limits.memory"             "$(jp pod $P '{.spec.containers[0].resources.limits.memory}')" 128Mi
eq "logger image"              "$(jp pod $P '{.spec.containers[1].image}')" busybox:1.36
eq "pod Running"               "$(jp pod $P '{.status.phase}')" Running
eq "both containers ready"     "$(jp pod $P '{.status.containerStatuses[*].ready}')" "true true"
contains "logger prints dates" "$(kubectl logs $P -c logger 2>/dev/null)" "UTC"

summary
