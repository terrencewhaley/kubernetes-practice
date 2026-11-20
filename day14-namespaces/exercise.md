# Day 14 – Namespaces

Put files in `day14-namespaces/`. Use explicit `-n` or `metadata.namespace`, never rely on the default.

## Tasks
1. Create namespace `app1-ns` **imperatively**.
2. Create namespace `app2-ns` **declaratively** from `app2-ns.yaml`, with the label `env=dev`.
3. In `app1-ns`: Deployment `backend` (2 replicas, `nginx:1.25`, containerPort 80), written in `backend.yaml` with
   `metadata.namespace` set (so `apply -f` needs no `-n`). Plus Service `backend-svc`: ClusterIP, port **9090** -> targetPort 80.
4. In `app2-ns`: Deployment `frontend` (1 replica, `nginx:1.25`), and a Pod `tester` (`busybox:1.36`, `sleep 3600`).
5. From `tester`, reach the backend by its **cross-namespace name** (`backend-svc.app1-ns:9090`).
6. Set the default namespace of your `kind-cka` context to `app1-ns` and confirm `kubectl get pods` now shows the backend pods without `-n`.

## When you're done
`./check.sh`, then **reset your default namespace** so the other checkers keep working:
`kubectl config set-context --current --namespace=default`

## Stretch
- From `tester`, does `wget http://backend-svc:9090` (short name) work? Why or why not?
- What are the four forms of the Service's DNS name, from shortest to fully qualified?
- `kubectl get svc -A` and `kubectl get all -n app1-ns`: what does each show that the other doesn't?
- What happens to everything inside a namespace when you delete it?
