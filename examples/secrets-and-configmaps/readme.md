##### ConfigMap

```
kubectl create configmap html-data-configmap --from-file=index.html
kubectl create configmap html-data-configmap --from-env-file=env-file.txt
kubectl create configmap html-data-configmap --from-literal=training=Kubernetes
```

```
kubectl get configmap html-data-configmap
kubectl get configmap html-data-configmap -o yaml
```

##### Secrets

```
kubectl create secret generic html-data-secret --from-file=index.html
kubectl create secret generic html-data-secret --from-env-file=env-file.txt
kubectl create secret generic html-data-secret --from-literal=training=Kubernetes
```

##### Docker registry secrets

```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

```
kubectl create secret docker-registry image-repo-secret --docker-server=https://index.docker.io/v1/ --docker-username=kamilbaran --docker-password='welcome' --docker-email=trainer@kamilbaran.pl
```
