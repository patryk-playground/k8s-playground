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

4. Update http-mongo single pod to use NodePort.

5. Add Ingress controller to `training-app-base` deployment.

Test Ingress controller connection to the `training` app:

    curl 10.0.3.203/patryk

    Version: 1     Response from: training-7c68cf76cf-774xg     Counter: 1

Hoever it won't work for the `counter` app, as it is unable to find a path inside `httpd` virtual host configuration:

    curl 10.0.3.203/patryk_counter

    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
    <html><head>
    <title>404 Not Found</title>
    </head><body>
    <h1>Not Found</h1>
    <p>The requested URL /patryk_counter was not found on this server.</p>
    <hr>
    <address>Apache/2.4.39 (Unix) Server at 10.0.3.203 Port 80</address>
    </body></html>

It can be seen in the logs of `counter` pod:

    kubectl logs --tail=1 pod/counter-7c7d58c897-z4hqp httpd
    
    172.16.69.192 - - [07/Jul/2020:12:45:44 +0000] "GET /patryk_counter HTTP/1.1" 404 286 "-" "curl/7.68.0"

Add `host` section to Ingress config and re-apply, test with custom header passed to `curl`:

    curl -H Host:patryk.example.com  10.0.3.203/patryk

    Version: 1     Response from: training-7c68cf76cf-774xg     Counter: 9

Update /etc/hosts and re-test with hostname:

    # /etc/hosts
    10.0.3.203      patryk.example.com

    kubectl get pods -l app=training
    
    NAME                        READY   STATUS    RESTARTS   AGE
    training-7c68cf76cf-5pffx   1/1     Running   0          121m
    training-7c68cf76cf-774xg   1/1     Running   0          121m
    training-7c68cf76cf-j7m8d   1/1     Running   0          121m

    curl patryk.example.com/patryk
    Version: 1     Response from: training-7c68cf76cf-5pffx     Counter: 9 
    curl patryk.example.com/patryk
    Version: 1     Response from: training-7c68cf76cf-774xg     Counter: 10 
    curl patryk.example.com/patryk
    Version: 1     Response from: training-7c68cf76cf-j7m8d     Counter: 7 
    curl patryk.example.com/patryk
    Version: 1     Response from: training-7c68cf76cf-5pffx     Counter: 10 

Expected outcome: The traffic is routed to the existing pods in round-robin fashion.

6. Split `counter` app deployment into 2 separate deployments, add labels, services (mongo, httpd) and ingress (httpd). 

Expected outcome:

    curl patryk.example.com/mongo/

    Exception: No suitable servers found (`serverSelectionTryOnce` set): [connection refused calling ismaster on 'counter-mongo:27017']

After adding mongo command with `--bind_ip_all` option as part of the custom `command` in mongo deployment, it works as expected:

    curl patryk.example.com/mongo/

    [..]
    I have been seen 3 times!!!<br />Response from: counter-httpd-7f554cf96b-5zntn</p></body></html>

# Day 3

1. Update mongo deployment to store data inside volume.

2. Apply configmaps (example 2).

3. Replace MONGO_CS env variable with secret. 

Test:

    curl patryk.example.com/mongo/

Exepcted outcome:

    I have been seen 1188 times!!!<br />Response from: counter-httpd-795f66645c-gxjhd
    
## Best practices

- In case of errors, update selector over label
