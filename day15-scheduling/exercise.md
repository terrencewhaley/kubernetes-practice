# Day 15 – Scheduling: nodeName, nodeSelector, taints and tolerations

Nodes in this cluster: `cka-control-plane`, `cka-worker`, `cka-worker2`. Put files in `day15-scheduling/`, default namespace.
Check where pods landed with `kubectl get pods -o wide`.

## Tasks
1. Pod `pinned` (`nginx:1.25`) **manually scheduled** onto `cka-worker2` with `nodeName` (write it in `pinned.yaml`).
2. Label node `cka-worker` with `disk=ssd` and node `cka-worker2` with `pool=ml`.
3. Pod `ssd-pod` (`nginx:1.25`) that must run on a node labeled `disk=ssd` (`nodeSelector`). Write it in `ssd-pod.yaml`.
4. Taint `cka-worker2` with `dedicated=ml:NoSchedule`.
5. Deployment `plain` (`nginx:1.25`, 4 replicas), created **after** the taint. No `plain` pod may land on `cka-worker2`.
6. Pod `ml-pod` (`nginx:1.25`) that runs on `cka-worker2` despite the taint: it needs a `toleration` **and** a `nodeSelector` for `pool=ml`. Write it in `ml-pod.yaml`.

## When you're done
`./check.sh`, then **clean up** so the taint doesn't affect other days:
```
kubectl taint nodes cka-worker2 dedicated=ml:NoSchedule-
kubectl label nodes cka-worker disk-
kubectl label nodes cka-worker2 pool-
kubectl delete pod pinned ssd-pod ml-pod; kubectl delete deploy plain
```

## Stretch
- `pinned` sits on a tainted node even though it doesn't tolerate the taint. Why? (Who enforces taints?)
- Does a toleration *attract* a pod to a node? What is the difference between a toleration and a nodeSelector?
- Change the taint effect to `NoExecute`. What happens to pods already running on `cka-worker2` that don't tolerate it?
- Why don't your `plain` pods land on `cka-control-plane`? Find the taint with `kubectl describe node cka-control-plane`.
- What happens to a pod whose `nodeSelector` matches no node? Check `kubectl describe pod` events.
