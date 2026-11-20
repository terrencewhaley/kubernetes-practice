# CKA practice

Companion exercises for the CloudWithVarJosh CKA 2025 course.

## Setup
```
kind create cluster --config kind-config.yaml   # cluster "cka": 1 control-plane, 2 workers
kubectl config use-context kind-cka
```

## Workflow per day
1. Read `dayNN-*/exercise.md` (task only, no answers).
2. Try the imperative route (`--dry-run=client -o yaml`, `kubectl explain`), then edit YAML in that folder.
3. `kubectl apply -f ...`, then run `./check.sh` in the day folder.
4. Only after attempting, compare with `solution/`.

## Days
| Folder | Topic |
| --- | --- |
| day09-pods | Pod YAML, multi-container, env, resources |
| day10-replicaset-deployment | ReplicaSet set-based selectors, Deployment rollout/rollback |
| day12-services | ClusterIP, NodePort, LoadBalancer, ExternalName |
| day13-imperative | Timed imperative drill: create/expose, `--dry-run`, test pods |
| day14-namespaces | Namespaces, cross-namespace DNS, default namespace in context |

Reset a day: `kubectl delete -f solution/<file>` (or delete the objects by name).
