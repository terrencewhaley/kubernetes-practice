# Day 12 – Services

Put everything in `day12-services/` (one file per object or one multi-doc file, your choice).

## Workloads
- Deployment `backend`: 2 replicas, label `app=backend`, image `nginx:1.25`, containerPort 80
- Deployment `frontend`: 2 replicas, label `app=frontend`, image `nginx:1.25`, containerPort 80

## Services
1. `backend-svc` – **ClusterIP**, port 80 -> targetPort 80, selects the backend pods
2. `frontend-np` – **NodePort**, port 80 -> targetPort 80, **nodePort 30080**, selects frontend pods
3. `frontend-lb` – **LoadBalancer**, port 80, selects frontend pods
   (on kind the external IP stays `<pending>`; that's expected)
4. `ext-svc` – **ExternalName** pointing at `example.com`

## Exam-style approach
- `kubectl create deploy backend --image=nginx:1.25 --replicas=2 --dry-run=client -o yaml`
- `kubectl expose deploy backend --name=backend-svc --port=80 --dry-run=client -o yaml`
- NodePort can't set a specific `nodePort` via `expose`; edit the YAML.
- `kubectl create svc externalname ext-svc --external-name example.com`

## Check
`./check.sh` (the NodePort test uses `localhost:30080`, mapped to a worker by `kind-config.yaml`)

## Stretch
- From a throwaway pod, resolve `backend-svc`, `backend-svc.default`, and `backend-svc.default.svc.cluster.local`.
- Break the selector on purpose: what does `kubectl get endpoints` show?
