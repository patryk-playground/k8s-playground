# Kubernetes controllers

```
kubectl get service,deploy,daemonset,statefulset,pod -o wide
```

##### standalone pod based on alpine

```
kubectl run --generator=run-pod/v1 -it alpine --image=alpine
apk add --update curl
kubectl exec -it alpine sh
```

#### Deployment
**default controller type suitable for most use cases**

run commands below in any other pod:
```
nslookup training
nslookup training.default.svc.cluster.local
```

try to scale up and down
```
kubectl scale deployment training --replicas=10
```

#### Daemonset
**when all (or some) nodes should run a single copy of a pod**

run commands below in any other pod:
```
nslookup training
nslookup training.default.svc.cluster.local
```

#### StetefulSet
**controller used to manage stateful applications**

run commands below in any other pod:
```
curl training-0.training
curl training-0.training.default.svc.cluster.local
curl training.default.svc.cluster.local
```
```
nslookup training-0.training
nslookup training
```
try to scale up and down
```
kubectl scale statefulset training --replicas=10
```

Notes:

- statefulset pods are created/destroyed on at a time. Destroying from latest (higher index).