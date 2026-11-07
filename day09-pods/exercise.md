# Day 9 – Pods & YAML basics

Write your answer in `day09-pods/web-pod.yaml` and apply it.

## Task
Create a Pod named `web-pod` in the `default` namespace:

- Labels: `app=web`, `tier=frontend`
- Container 1: name `web`, image `nginx:1.25`, containerPort `80`,
  env var `APP_ENV=dev`,
  resources: requests `cpu: 100m` / `memory: 64Mi`, limits `memory: 128Mi`
- Container 2: name `logger`, image `busybox:1.36`, running a shell loop that
  prints the date every 5 seconds (`while true; do date; sleep 5; done`)

## Exam-style approach
1. Generate a skeleton imperatively: `kubectl run web-pod --image=nginx:1.25 --dry-run=client -o yaml > web-pod.yaml`
2. Use `kubectl explain pod.spec.containers.resources` (and friends) instead of memorizing fields.
3. Add the second container and the rest by editing.
4. `kubectl apply -f web-pod.yaml`

## Check
`./check.sh`

## Stretch
- Why does the `logger` container need `command`, not just `args`?
- Run `kubectl logs web-pod -c logger` and `kubectl exec -it web-pod -c web -- env | grep APP_ENV`.
