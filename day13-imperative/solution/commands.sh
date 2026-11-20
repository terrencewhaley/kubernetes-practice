# 1
kubectl create deployment orders --image=nginx:1.25 --replicas=3 --port=80
kubectl expose deployment orders --name=orders-svc --port=8080 --target-port=80

# 2
kubectl create deployment store --image=nginx:1.25 --replicas=2 --port=80
kubectl expose deployment store --name=store-np --type=NodePort --port=80 --target-port=80 \
  --dry-run=client -o yaml > store-np.yaml
# edit store-np.yaml: under ports add   nodePort: 30090
kubectl apply -f store-np.yaml

# 3  (args after -- become the container's command)
kubectl run probe --image=busybox:1.36 --restart=Never --labels="role=tester,team=qa" -- sleep 3600

# 4
kubectl create deployment batch --image=nginx:1.25 --replicas=1 --dry-run=client -o yaml > batch.yaml
kubectl apply -f batch.yaml --dry-run=server

# 5
kubectl run curltest --rm -it --restart=Never --image=busybox:1.36 -- wget -qO- http://orders-svc:8080
