# Day 10 – ReplicaSet, selectors, Deployment, rollouts

## Part A – ReplicaSet with a set-based selector
Write `rs.yaml`:

- ReplicaSet `api-rs`, 3 replicas
- Selector uses `matchExpressions` (not `matchLabels`):
  - `app` **In** `[api]`
  - `env` **Exists**
- Pod template labels: `app=api`, `env=prod`; one container `api`, image `nginx:1.24`

Hint: `kubectl explain rs.spec.selector.matchExpressions`

## Part B – Deployment, update, rollback
Write `deploy.yaml`:

- Deployment `shop-deploy`, 4 replicas, label/selector `app=shop`
- Container `shop`, image `nginx:1.24`
- Strategy: `RollingUpdate` with `maxSurge: 1`, `maxUnavailable: 0`

Then, **using kubectl commands**:
1. Apply it, and annotate revision 1 with a change-cause (`kubectl annotate deploy shop-deploy kubernetes.io/change-cause="initial nginx 1.24"`).
2. Update the image to `nginx:1.25` (`kubectl set image`), annotate a change-cause for it.
3. Look at `kubectl rollout history deploy/shop-deploy`.
4. Roll back to revision 1 with `kubectl rollout undo --to-revision=1`.

Imperative skeleton: `kubectl create deploy shop-deploy --image=nginx:1.24 --replicas=4 --dry-run=client -o yaml`

## Check
`./check.sh`

## Stretch
- Delete one `api-rs` pod: what happens? Remove the `env` label from one pod: what happens?
- After rollback, which revision numbers exist and why?
