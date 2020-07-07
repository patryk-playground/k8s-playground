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



    
## Best practices

- In case of errors, update selector over label
