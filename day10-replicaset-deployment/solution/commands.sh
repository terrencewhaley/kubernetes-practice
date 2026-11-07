kubectl apply -f deploy.yaml
kubectl annotate deploy shop-deploy kubernetes.io/change-cause="initial nginx 1.24"
kubectl set image deploy/shop-deploy shop=nginx:1.25
kubectl annotate deploy shop-deploy kubernetes.io/change-cause="upgrade to nginx 1.25" --overwrite
kubectl rollout status deploy/shop-deploy
kubectl rollout history deploy/shop-deploy
kubectl rollout undo deploy/shop-deploy --to-revision=1
kubectl rollout status deploy/shop-deploy
