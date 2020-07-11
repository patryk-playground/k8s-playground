## CKA and CKAD sample exam tasks part 1

### Task 1
Environment: your private cluster
Create namespace called: web-servers
Start Nginx web server in a single pod called app-nginx-118. Use the official 1.18 image based on the Alpine Linux.

Solution:

    k config get-contexts
    k config set-context web-servers --cluster=kubernetes --user=kubernetes@admin --namespace=web-servers
    k create ns web-servers
    k run app-nginx-118 --image=nginx:1.18  --dry-run=client -o yaml > task01.yaml
    k apply -f task01.yaml 
    k get pods

### Task 2
Environment: your private cluster, namespace: web-servers
Create a new deployment called nginx-t2v1. Use the latest Nginx image based on the Alpine.
Scale this deployment to 3 replicas and expose it by a service type with the same name on port 30082 on all the nodes.

    k create deployment nginx-t2v1 --image=nginx:alpine --dry-run=client -o yaml >task_02.yaml
    k create service nodeport  nginx-t2v1 --tcp=80:80 --node-port=30082 --dry-run=client -o yaml  >> task02.yaml

### Task 3
Environment: your private cluster
List all the pods from a kube-system namespace sorted by the node name.
Write the output into /home/student/training/tasks/task-3.txt on your desktop machine. The output should include the node name and can't be modified manually.

    k get po --namespace=kube-system --sort-by=.spec.nodeName -o wide  >  /home/student/training/tasks/task-3.txt

### Task 4
Environment: your private cluster
List all your pods from all namespaces with the CPU and memory current consumption. Sort the list descending by the memory column.
Write the output into /home/student/training/tasks/task-4-iIlLo0O.txt on your desktop machine.

    k top pod --all-namespaces --sort-by=memory >/home/student/training/tasks/task-4-iIlLo0O.txt

### Task 5
Environment: shared cluster
Create a config map in the default namespace.
The name of the config map should be your name.
It should contain the following keys: number, colour, brand, month. The values should correspond to the keys, but you can choose whatever you like.

    k create configmap patryk --from-env-file=task05.env --namespace=default --dry-run=client -o yaml >task05.yaml
    k apply -f task05.yaml
    k get configmaps --context=k8s-shared-admin@k8s-shared --namespace=default 

### Task 6
Environment: shared cluster
List all pods that have the tier label set to control-plane value.
Write the output into /home/student/training/tasks/task-6-h43kj2a2.txt on your desktop machine.

    k get po --context=k8s-shared-admin@k8s-shared --all-namespaces -l tier=control-plane >/home/student/training/tasks/task-6-h43kj2a2.txt

### Task 7
Environment: your private cluster, namespace: web-servers
Create config map called nginx-ex7-data. It should contain index.html file that is located here: http://ds.kamilbaran.pl/training/tasks/7/index.html
Create deployment nginx-t7v1 that will use this config map to overwrite the default index.html file.
Create service nginx-t7v1 that will expose this app on port 30087.

    k create configmap nginx-ex7-data --from-file=index.html --dry-run=client -o yaml >task07.yaml
    k create deployment nginx-t7v1 --image=nginx:1.18.0 --namespace=web-servers --dry-run=client -o yaml >>task07.yaml
    k create service nodeport nginx-t7v1 --tcp=80:80 --node-port=30087 --dry-run=client -o yaml >>task07.yam

Update YAML with volume defintion to mount config map to `/usr/share/nginx/html` folder.
Test:

    curl 10.0.3.243:30087

Expected outcome: 

    <html><head><title>Task 7</title></head><body><p>This is the content for the Task 7.</p></body></html>

### Task 8
Environment: your private cluster
Play with any other web server. You can use any image you like but do not use Nginx.
You can use any namespace, any controller, any way of exposing it.
Add a label task of value eight to all resources that you will create during this task.
