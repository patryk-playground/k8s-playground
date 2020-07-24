## CKA and CKAD sample exam tasks part 1

### Task 1
Environment: your private cluster
Create namespace called: web-servers
Start Nginx web server in a single pod called app-nginx-118. Use the official 1.18 image based on the Alpine Linux.

Solution:

    k config get-contexts
    k config set-context web-servers --cluster=kubernetes --user=kubernetes@admin --namespace=web-servers
    k create ns web-servers
    k run app-nginx-118 --image=nginx:1.18-alpine  --dry-run=client -o yaml > task01.yaml
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

    k create deployment task08 --image=httpd:2.4-alpine --namespace=web-servers  --dry-run=client -o yaml >task08.yaml 
    k create svc nodeport httpd-task08 --tcp=80:80 --node-port=30900 --dry-run=client -o yaml >> task08.yaml 

    Add labels and ingress definition. Add host configuration inside ingress. 

### Task 9 - growing the cluster
Environment: your private cluster
Add the third worker node to your cluster - you should see a VM called your-name-w3.
Connect to the new VM and install necessary Kubernetes components.
Then on the master node, generate the new token and join command. The old one that you used during the course won't work as it has already expired.
Execute join command on the new worker node and verify that you see one master and three workers on the node list.
Hints: hint 1, hint 2 hint 3, hint 4

Solution: After logged in to new worker node, install docker and k8s components: 

    sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && apt-cache madison docker-ce
    sudo apt-get install -y docker-ce=5:19.03.8~3-0~ubuntu-bionic
    sudo usermod -aG docker student

    sudo apt-get update && sudo apt-get install -y apt-transport-https bash-completion curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt-get update && sudo apt-get install -y kubeadm=1.17.2-00 kubectl=1.17.2-00 kubelet=1.17.2-00
    source <(kubectl completion bash) && echo "source <(kubectl completion bash)" >> ~/.bashrc
    source <(kubeadm completion bash) && echo "source <(kubeadm completion bash)" >> ~/.bashrc

Generate token and join worker node to the master:

    kubeadm token create --print-join-command
    kubeadm join 10.0.3.242:6443 --token xyz


### Task 10 - labelling nodes
Environment: your private cluster
Add labels datacenter and type to the nodes.
Master node and worker nodes w1 and w2 should have datacenter value set to PL and worker node w3 set to DE.
Worker node w1 should have type value set to data-node and worker nodes w2 and w3 set to computing-node.

    kubectl get node --selector='!node-role.kubernetes.io/master'
    
    k label nodes k8s-master datacenter=PL
    k label nodes k8s-worker-1 datacenter=PL type=data-node
    k label nodes k8s-worker-2 datacenter=PL type=computing-node
    k label nodes k8s-worker-3 datacenter=DE type=computing-node

### Task 11 - rolling upgrade
Environment: your private cluster, namespace: upgrades
Create a new deployment called t11-app and a service with the same name. Use the image nginx:alpine.
Scale the deployment to 5 replicas and verify that it works.
Upgrade the application to the new version. Use the image httpd:alpine. Verify that it works.
Downgrade to the first version, verify that it works and scale the deployment to 0 (zero) replicas.

### Task 12 - rolling upgrade
Environment: your private cluster, namespace: upgrades
Create a new deployment called t12-app and a service with the same name. Use the image nginx:alpine.
Scale the deployment to 2 replicas and verify that it works.
Upgrade the application to the new version. Use the image tomcat:jdk11-openjdk-slim.
Troubleshoot the application.
Hints: hint 1

### Task 13 - canary deployment
Environment: your private cluster, namespace: upgrades
There is an app already running in your cluster. Service called t13-app is sending all the requests to version v1 of the app.
Change the service to send requests to both v1 and v2 version of the app. Set the ratio to 3:1 (25% of requests to the version v2).
You need to start all the missing resources. Do not modify labels of already created resources and make sure that the labels of new resources are using the same label names.

### Task 14 - troubleshooting
Environment: your private cluster
There is an app already running in your cluster. All of its components are labelled app=app-te7b.
Fix the problem with the application.
