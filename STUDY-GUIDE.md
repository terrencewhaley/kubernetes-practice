# CKA Study Guide (living document)

Rules of thumb and exam tips collected while working through the course exercises.
Add to it as new days are covered. Items marked *(course)* come from the lecture material and have not been practiced yet.

## 1. Working method

- **Always check your context first:** `kubectl config current-context` (this kubeconfig also holds docker-desktop and a real AWS EKS cluster). On the exam, run the context command shown at the top of each task.
- **Imperative first, then edit:** generate a skeleton, don't type YAML from scratch.
  `kubectl run|create|expose ... --dry-run=client -o yaml > file.yaml`
- **Use `kubectl explain` instead of memorizing fields:** `kubectl explain pod.spec.containers.resources`, `kubectl explain rs.spec.selector.matchExpressions`. Add `--recursive` to see the whole tree.
- **When you freeze, use the lookup ladder in this order** (all allowed on the exam):
  1. `kubectl <verb> <thing> -h`: the examples are at the top, and the flag list shows what can be set imperatively (e.g. `kubectl create service nodeport -h` has `--node-port`).
  2. `kubectl explain <path>` for YAML fields.
  3. kubernetes.io docs (search the exact task, e.g. "debug services"), including the kubectl cheat sheet.
  Don't search anywhere else; the first two answer most questions in seconds.
- **Throwaway test pod template (memorize this one):**
  `kubectl run tmp --rm -it --restart=Never --image=busybox:1.36 -- wget -qO- http://SERVICE:PORT`
  (`--rm` deletes it afterward, `--restart=Never` makes it a plain Pod, everything after `--` is the command.) Add `-n NS` for another namespace.
- Keep "why does it work this way?" questions for review time. During a timed task, finish first and note the question to study later.
- Add only what the task asks for. Extra fields cost time and can trip checkers.
- `kubectl get pods --show-labels` and `kubectl get endpoints` are the fastest debug views for selector problems.

## 2. Pods (Day 9)

- **Most of a Pod's spec is immutable.** `kubectl apply` on a changed spec fails with `Forbidden`. Recreate it: `kubectl delete pod X` then `apply`, or `kubectl replace --force -f file.yaml`. This is why Deployments exist.
- **`command` vs `args`:** `command` replaces the image's `ENTRYPOINT`, `args` replaces its `CMD` and is passed to the entrypoint.
  - busybox has no entrypoint, so `args: ["sh","-c","..."]` works. Images with an entrypoint (e.g. nginx) need `command` to run a shell.
  - A bare string like `args: ["while true; do ...; done"]` fails: Kubernetes tries to run a program with that literal name. Wrap shell code in `sh -c`.
- The API server fills in many defaults (`restartPolicy`, `imagePullPolicy`, `dnsPolicy`, ...). `kubectl get pod X -o yaml` shows far more than you wrote; that's why imperative commands need fewer arguments.
- Multi-container pods: `kubectl logs POD -c NAME` and `kubectl exec -it POD -c NAME -- ...`.
- Resources: `requests` drive scheduling, `limits` are enforced at runtime. A CPU limit set too low throttles the container; a memory limit exceeded gets it OOM-killed.

## 3. Labels and selectors (Day 10)

- A selector decides "which pods are mine"; the pod `template` decides what to create. **Template labels must satisfy the selector** or the object is rejected.
- **`matchLabels`** = exact equality, all pairs ANDed. Use this by default.
- **`matchExpressions`** = for logic equality can't express. All entries are ANDed.

  | operator | matches when | `values` needed |
  |---|---|---|
  | `In` | label exists and value is in the list | yes |
  | `NotIn` | value not in the list (or label missing) | yes |
  | `Exists` | label key is present, any value | no |
  | `DoesNotExist` | label key absent | no |

- Each expression is its own list item (`key`, `operator`, `values`). `matchExpressions` belongs only under `spec.selector`, never under `metadata`.
- **Services use a plain key/value map** for `spec.selector` (equality only, no `matchLabels` key). Deployments, ReplicaSets and Jobs use the `matchLabels` / `matchExpressions` form.
- **Changing a ReplicaSet's template does not touch existing pods**, it only affects pods created afterward. To replace them: `kubectl delete pod -l app=api`.
- ReplicationController is legacy (equality selectors only); ReplicaSet is its replacement; you normally use a Deployment, which manages ReplicaSets for you.

## 4. Deployments and rollouts (Day 10)

- Skeleton: `kubectl create deploy NAME --image=IMG --replicas=N --dry-run=client -o yaml`
- Change the image: `kubectl set image deploy/NAME CONTAINER=IMAGE`
- Record why: `kubectl annotate deploy NAME kubernetes.io/change-cause="..." --overwrite`
- Watch and inspect: `kubectl rollout status|history deploy/NAME`
- Roll back: `kubectl rollout undo deploy/NAME [--to-revision=N]`
- Rolling update strategy: `maxSurge` (extra pods allowed) and `maxUnavailable` (pods allowed down). `maxSurge: 1, maxUnavailable: 0` means capacity never drops during an update.
- An undo to an old revision re-uses that revision's pod template, and the old revision number is consumed: it reappears as the newest revision. Verified: after updating 1.24 -> 1.25 and `undo --to-revision=1`, history shows revisions 2 (1.25) and 3 (1.24); revision 1 is gone. The change-cause text travels with the template, so revision 3 shows the old "initial" cause.
- Old ReplicaSets are kept at 0 replicas (`kubectl get rs`) so rollbacks are instant. History depth is `spec.revisionHistoryLimit` (default 10).

## 5. Services (Day 12)

| Type | Reachable from | Notes |
|---|---|---|
| ClusterIP (default) | inside the cluster | stable virtual IP + DNS name |
| NodePort | `nodeIP:nodePort` (default range 30000-32767) | builds on ClusterIP |
| LoadBalancer | external IP from a cloud/LB provider | builds on NodePort; stays `<pending>` on kind |
| ExternalName | inside the cluster | DNS CNAME to an external host; no proxying, no selector |

- Know the three ports: `port` (the Service's), `targetPort` (the container's), `nodePort` (on each node).
- `kubectl expose deploy NAME --port=80 --target-port=80 --type=NodePort` works, but **`expose` has no `--node-port` flag**, so for a specific nodePort either edit the generated YAML, or use `kubectl create service nodeport NAME --tcp=80:80 --node-port=30090`.
- **`expose` vs `create service`:** `expose deploy X` reads the Deployment and copies its pod selector, so the Service is guaranteed to match. `create service ...` knows nothing about Deployments and sets the selector to `app=<service-name>`, which only matches if your pods happen to carry that label (fix it by editing the YAML or naming the service after the app). When the selector matters, prefer `expose`.
- `kubectl create svc externalname NAME --external-name host.example.com`
- **Empty endpoints = selector doesn't match any pod's labels.** Check `kubectl get endpoints NAME` first.
- Test from inside the cluster: `kubectl run tmp --rm -it --restart=Never --image=busybox:1.36 -- wget -qO- http://SVC`
- On kind, host access to a NodePort needs `extraPortMappings` in the cluster config (this repo maps 30080).

## 6. Imperative commands (Day 13) *(course)*

- Flags worth knowing: `--dry-run=client` (no server contact), `--dry-run=server` (validates against the API server), `-o yaml`, `--rm`.
- **Do you need a file at all?** Only if you must edit something flags can't set. Speed order: (1) flags, (2) generate with `--dry-run=client -o yaml`, edit, apply, (3) hand-written YAML.
  - If the object only needs to exist, skip the file: `kubectl create deploy X --image=IMG --dry-run=client -o yaml | kubectl apply -f -`
  - `>` **overwrites** the file each time; `>>` appends. Use a new filename per object, or append with a `---` line between objects.
  - `kubectl expose deploy X --dry-run=client` reads the Deployment from the cluster, so the Deployment must already exist.
  - For a one-line tweak to a live object, `kubectl edit TYPE NAME` can be faster than a file.
- Pod labels at creation: `kubectl run NAME --image=IMG --labels="a=b,c=d"`; `--restart=Never` makes it a plain Pod.
- Pod labels set on a Deployment's template can't be set imperatively; edit the YAML.
- Multiple objects in one file are separated by `---`.

## 7. Namespaces (Day 14) *(course)*

- Defaults: `default`, `kube-system`, `kube-public`, `kube-node-lease` (plus `local-path-storage` on kind).
- Create: `kubectl create namespace NAME` or YAML `kind: Namespace`.
- Scope flags: `-n NAME` for one namespace, `-A` for all.
- Cross-namespace service access uses `SERVICE.NAMESPACE` (e.g. `backend-svc.app1-ns:9090`).
- Change the default for your context: `kubectl config set-context --current --namespace=NAME`. Remember to check which namespace you're in before answering an exam task.

## 8. Security and ML angles (add as the course reaches them)

- Security: RBAC, ServiceAccounts, NetworkPolicy, Secrets, `securityContext` (non-root, read-only filesystem, dropped capabilities). CKA is the prerequisite for CKS.
- MLOps: resource requests/limits, Jobs/CronJobs, taints/tolerations and node affinity (GPU nodes), PersistentVolumes for data and checkpoints.

## 9. Gotchas I have hit

- kubectl context drifted to the wrong cluster between sessions.
- A spec mismatch (`env: production` vs the required `prod`) fails a checker even though the YAML is valid.
- Linter warnings (e.g. missing resources on a container) are policy, not Kubernetes requirements.
