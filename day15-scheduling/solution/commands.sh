# 1  nodeName bypasses the scheduler entirely (kubelet on that node just runs it)
kubectl run pinned --image=nginx:1.25 --dry-run=client -o yaml > pinned.yaml
#   add under spec:   nodeName: cka-worker2
kubectl apply -f pinned.yaml

# 2
kubectl label node cka-worker disk=ssd
kubectl label node cka-worker2 pool=ml

# 3  add under spec:   nodeSelector: {disk: ssd}
kubectl run ssd-pod --image=nginx:1.25 --dry-run=client -o yaml > ssd-pod.yaml
kubectl apply -f ssd-pod.yaml

# 4
kubectl taint nodes cka-worker2 dedicated=ml:NoSchedule

# 5
kubectl create deploy plain --image=nginx:1.25 --replicas=4
kubectl get pods -l app=plain -o wide

# 6  add under spec:
#   nodeSelector: {pool: ml}
#   tolerations:
#   - {key: dedicated, operator: Equal, value: ml, effect: NoSchedule}
kubectl run ml-pod --image=nginx:1.25 --dry-run=client -o yaml > ml-pod.yaml
kubectl apply -f ml-pod.yaml

# cleanup
kubectl taint nodes cka-worker2 dedicated=ml:NoSchedule-
kubectl label nodes cka-worker disk-
kubectl label nodes cka-worker2 pool-
kubectl delete pod pinned ssd-pod ml-pod; kubectl delete deploy plain
