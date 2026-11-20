# Day 13 – Imperative commands (timed drill)

Goal: finish in **under 10 minutes**, using imperative commands. Hand-edit YAML only where the task says so.
Start a timer. All objects go in the `default` namespace. (Day 12's objects can stay; these names don't collide.)

## Tasks
1. Deployment `orders`: 3 replicas, image `nginx:1.25`, containerPort 80.
   Service `orders-svc`: ClusterIP, port **8080** -> targetPort 80, exposing `orders`.
2. Deployment `store`: 2 replicas, image `nginx:1.25`, containerPort 80.
   Service `store-np`: NodePort, port 80 -> targetPort 80, **nodePort 30090**.
   (Generate the Service YAML with `expose --dry-run=client -o yaml`, add the nodePort by hand, apply.)
3. A bare Pod `probe`: image `busybox:1.36`, never restarts, labels `role=tester` and `team=qa`, running `sleep 3600`.
4. Generate (but **do not apply**) a Deployment manifest for `batch` (1 replica, `nginx:1.25`) into `day13-imperative/batch.yaml`.
   Validate it with `--dry-run=server`.
5. From a throwaway pod (`--rm`), fetch `http://orders-svc:8080` and confirm you get the nginx page.

## Rules for the drill
- No hand-written YAML from scratch.
- Look things up with `kubectl explain` or `kubectl create deploy -h` rather than guessing.
- Note which task slowed you down and why.

## Check
`./check.sh`

## Stretch
- What does `--dry-run=server` catch that `--dry-run=client` doesn't?
- Why can't you set pod labels on a Deployment's template with `kubectl create deploy`?
