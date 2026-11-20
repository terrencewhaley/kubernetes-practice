# 1 & 2
kubectl create namespace app1-ns
kubectl apply -f app2-ns.yaml

# 3  (backend.yaml carries metadata.namespace: app1-ns)
kubectl apply -f backend.yaml
kubectl expose deployment backend -n app1-ns --name=backend-svc --port=9090 --target-port=80

# 4
kubectl create deployment frontend -n app2-ns --image=nginx:1.25
kubectl run tester -n app2-ns --image=busybox:1.36 --restart=Never -- sleep 3600

# 5
kubectl exec -n app2-ns tester -- wget -qO- http://backend-svc.app1-ns:9090

# 6
kubectl config set-context --current --namespace=app1-ns
kubectl get pods

# reset afterwards
kubectl config set-context --current --namespace=default

# DNS forms for a Service (short name only works inside the same namespace):
#   backend-svc  |  backend-svc.app1-ns  |  backend-svc.app1-ns.svc  |  backend-svc.app1-ns.svc.cluster.local
