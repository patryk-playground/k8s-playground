## Day 1, run deployment in the user namespace

    kubectl create namespace patryk
    kubectl config set-context --current --namespace=patryk
    kubectl apply -f training-app-base.yaml
    kubectl get deploy,pods -o wide

Delete from default ns:

     kubectl delete -f training-app-base.yaml --namespace default

Delete pods but leave deployment and service intact:

    kubectl get svc,deploy,pod -l app=training --all-namespaces
    kubectl delete pod -l app=training

Deploy app-client pod:

    kubectl apply -f training-app-client.yaml

Show the logs in separate terminal windows:

    kubectl logs --tail=1 --follow training-app-client

Edit pod metadata directly in K8S (change label from training to test):

    kubectl get svc,deploy,ep,pod -o wide -L app
    kubectl edit pod <pod-name>

Exepcted outcome: 4 training-xxx pods are running.

# Day 2

Remove all resources:

    kubectl delete all --all

1. Create a deployment with a single pod that run httpd and mongo together, test mongo counter is increased. 

    kubectl apply exercises/httpd-mongo-single-pod.yaml
    kubectl exec -it pod/demo1-775bb855c5-f4h52 -- sh -c 'apk add curl; curl http://localhost/mongo/ '

2. Apply `training-app-base` deployment and search resources by label, fix missing label to identify all resources created in (1)

    kubectl apply -f training-app-base.yaml
    kubectl get svc,po,ep,deploy -o wide -l app=training
    kubectl get svc,po,ep,deploy -o wide -l app=demo1

3. Change LB type to NodePort and set custom NodePort parameter for the `training-app-base` deployment.

Expected result: 

    kubectl get pod,svc,ep,deploy  -l app=training 
    
    NAME                            READY   STATUS    RESTARTS   AGE
    pod/training-7c68cf76cf-5pffx   1/1     Running   0          18m
    pod/training-7c68cf76cf-774xg   1/1     Running   0          18m
    pod/training-7c68cf76cf-j7m8d   1/1     Running   0          18m

    NAME               TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
    service/training   NodePort   10.98.196.99   <none>        80:31081/TCP   18m

    NAME                 ENDPOINTS                                           AGE
    endpoints/training   172.16.140.6:80,172.16.69.193:80,172.16.69.254:80   18m

    NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/training   3/3     3            3           18m
    student@student:~/code/k8s-playground/training-app$ 

Grab nodes internal IPs first:

    kubectl get nodes -o wide

    NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
    k8s-master     Ready    master   15d   v1.18.4   10.0.3.205    <none>        Ubuntu 20.04 LTS   5.4.0-39-generic   docker://19.3.11
    k8s-worker-1   Ready    <none>   15d   v1.18.4   10.0.3.201    <none>        Ubuntu 20.04 LTS   5.4.0-39-generic   docker://19.3.11
    k8s-worker-2   Ready    <none>   15d   v1.18.4   10.0.3.202    <none>        Ubuntu 20.04 LTS   5.4.0-39-generic   docker://19.3.11
    k8s-worker-3   Ready    <none>   15d   v1.18.4   10.0.3.203    <none>        Ubuntu 20.04 LTS   5.4.0-39-generic   docker://19.3.11
    k8s-worker-4   Ready    <none>   15d   v1.18.4   10.0.3.204    <none>        Ubuntu 20.04 LTS   5.4.0-39-generic   docker://19.3.11

The app can accessed directly by the node port connection:

    curl 10.0.3.202:32080

    Version: 1     Response from: training-7c68cf76cf-j7m8d     Counter: 2 

## Best practices

- In case of errors, update selector over label
