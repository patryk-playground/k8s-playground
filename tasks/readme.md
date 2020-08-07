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

    k create ns upgrades
    k config set-context upgrades  --namespace=upgrades --cluster=kubernetes --user=kubernetes-admin 
    k config use-context upgrades

    k create deployment t11-app --image=nginx:alpine -n upgrades --dry-run=client -o yaml >task11.yaml
    k create svc nodeport t11-app -n upgrades --tcp=80:80 --node-port=30911 --dry-run=client -o yaml >>task11.yaml 
    curl 10.0.3.243:30911 
    k get pods -l app=t11-app | tail -5  | awk '{print $1}' | xargs -I name kubectl logs name

    k set image deployment/t11-app --namespace=upgrades nginx=httpd:alpine  --dry-run=client -o yaml  >task11_rolling_update.yaml

    k rollout history deployment t11-app 
    k rollout undo deployment t11-app --to-revision=1 
    
    k get pods -l app=t11-app | tail -5  | awk '{print $1}' | xargs -I name kubectl logs name
    k scale deployment t11-app --replicas=0 

### Task 12 - rolling upgrade
Environment: your private cluster, namespace: upgrades
Create a new deployment called t12-app and a service with the same name. Use the image nginx:alpine.
Scale the deployment to 2 replicas and verify that it works.
Upgrade the application to the new version. Use the image tomcat:jdk11-openjdk-slim.
Troubleshoot the application.
Hints: hint 1

    k create deployment t12-app --image=nginx:alpine -n upgrades --dry-run=client -o yaml >task12.yaml
    k create svc nodeport t12-app -n upgrades --tcp=80:80 --node-port=30912 --dry-run=client -o yaml >>task12.yaml 
    curl 10.0.3.243:30912
   
    k get pods -l app=t12-app | tail -2  | awk '{print $1}' | xargs -I name kubectl logs name
    k set image deployment/t12-app --namespace=upgrades nginx=tomcat:jdk11-openjdk-slim

Problem:  Fix targetPort in service to point at Tomcat HTTP port.

### Task 13 - canary deployment
Environment: your private cluster, namespace: upgrades
There is an app already running in your cluster. Service called t13-app is sending all the requests to version v1 of the app.
Change the service to send requests to both v1 and v2 version of the app. Set the ratio to 3:1 (25% of requests to the version v2).
You need to start all the missing resources. Do not modify labels of already created resources and make sure that the labels of new resources are using the same label names.

Get existing resources:

    k get all -l name=t13-app
    k get deploy t13-app -o yaml  > task13_deploy.yaml
    k get svc t13-app -o yaml  > task13_service.yaml

    k scale --replicas=3 deployment t13-app
    k describe deployments.apps t13-app
    k create deployment t13-app --image=kamilbaran/training:training-app-v2 --namespace=upgrades --dry-run=client -o yaml > task13_canary.yaml

Change deployment name to avoid overriding existing deployment, rename label app=>name and add version=v2 label. Apply.

    kubectl edit service t13-app
    Update service by removing version number, so that traffic will be spread between existing pods in round-robin fashion.


### Task 14 - troubleshooting
Environment: your private cluster
There is an app already running in your cluster. All of its components are labelled app=app-te7b.
Fix the problem with the application.

    k get all -l app=app-te7b --namespace web-servers
    k config use-context web-servers
    k describe svc t14-app 
    k edit svc t14-app

Add missing selector to point at the existing deployment, test with curl:

    curl node_ip:nodeport

Expected outcome: Nginx home page returned.

## Task 15 - controllers

Environment: your private cluster, namespace: controllers
Start the app on all worker nodes in the cluster.
Expose the app to external traffic.
Call it app-t15v1, use image kamilbaran/training:app-v1.

    k create ns controllers
    k config set-context controllers --cluster=kubernetes --user=kubernetes-admin --namespace=controllers
    k config use-context controllers
    k create service nodeport app-t15v1 --tcp=80:80 --node-port=30915 --dry-run=client -o yaml >> task15.yaml
    
Edit label of pods / service and apply:

    k apply -f task15.yaml

Test:

    curl node_ip:80

## Task 16 - controllers

Environment: your private cluster, namespace: controllers
Start the app on all nodes (including control-plane node) in the cluster.
Expose the app to external traffic.
Call it app-t16v1, use image kamilbaran/training:app-v1.

Copy the content from previous task and add section inside pod spec:

    tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule

Apply all, check all resources are deployed including master node.

    k get all -l app=app-t16v1

## Task 17 - controllers

Environment: your private cluster, namespace: controllers
Start the app on all nodes labelled datacenter=PL.
Expose the app to external traffic.
Call it app-t17v1, use image kamilbaran/training:app-v1.

Copy content from task 16 and add nodeSelector with a label under pod spec.
Apply and test.
    
## Task 18 - controllers

Environment: your private cluster, namespace: controllers
Start the stateful app with three replicas. Choose the best type of controller.
Call it app-t18v1, use image kamilbaran/training:app-v1.
Run nslookup app-t18v1 in one of the created pods and write the output into /home/student/training/tasks/task-18.txt on your desktop machine.

Copy Stateful Set config from docs and update it to create 3 replicas.
Query it and dump nslookup result:

    k exec -it app-t18v1-0  -- nslookup app-t18v1 > /home/student/training/tasks/task-18.txt


## Task 19 - controllers, counter app

Environment: your private cluster, namespace: counter
Start the MongoDB with three replicas.
Call it mongo, use image kamilbaran/training:mongo.
In this task, you should skip volumes and MongoDB data persistence.
Overwrite the image default CMD. Start mongod process with the following flags: --bind_ip_app --replSet=test
Change the DNS configuration of the stateful set by adding searches: mongo.counter.svc.cluster.local
Hints: hint 1

Copy and configure Stateful Set based on official docs. Add DNSConfig section with custom search.
Apply and test logs:

    k exec -it mongo-2 -n counter -- cat /etc/resolv.conf
    k logs mongo-2 -n counter

## Task 20 - controllers, counter app

Environment: your private cluster, namespace: counter
Configure the MongoDB from a previous task.
Start a shell in the mongo-0 pod and then connect to MongoDB running in this pod by running mongo command. This will connect to the instance running on the localhost.
In the MongoDB shell run the following commands:
    rs.initiate()
    rs.add("mongo-1")
    rs.add("mongo-2")
After executing the above commands, you can check the status of a MongoDB replica set. If you see the following output, it means that the replica was initialised successfully.
    rs.status().members[0].stateStr should show PRIMARY
    rs.status().members[1].stateStr should show SECONDARY
    rs.status().members[2].stateStr should show SECONDARY
Close MongoDB shell and Linux shell.

After initializing mongo instance, the expected status showed up:

    test:PRIMARY> rs.status().members[0].stateStr
    PRIMARY
    test:PRIMARY> rs.status().members[1].stateStr
    SECONDARY
    test:PRIMARY> rs.status().members[2].stateStr
    SECONDARY


## Task 21 - counter app

Environment: your private cluster, namespace: counter
Create a new deployment called counter-v2. Use the image kamilbaran/training:httpd and expose it to external traffic by creating a service with the same name.
Set environment variable MONGO_CS to mongodb://mongo-0:27017,mongo-1:27017,mongo-2:27017/?replicaSet=test
Change the DNS configuration of the deployment by adding searches: mongo.counter.svc.cluster.local
Verify that it works.

    k create deployment counter-v2 --image=kamilbaran/training:httpd -n counter --dry-run=client -o yaml  >task21.yaml
    k create service nodeport counter-v2 --tcp=80:80 -n coutner --dry-run=client -o yaml >>task21.yaml

Test:

    curl 10.0.3.244:31552/mongo/

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Docker Training - MongoDB Counter</title>
    </head>
    <body><p>
    I have been seen 7 times!!!<br />Response from: counter-v2-774fc84f74-z8d6d</p></body></html>


## Task 22 - counter app

Environment: your private cluster, namespace: counter
Create a new deployment called counter-v3. Use the same configuration as in task 21 with one exception.
This time set environment variable MONGO_CS based on the value stored in secret. Call the secret counter-config.
Verify that it works.

Copy initial content from task21. Update labels. Create secret:

    k create secret generic counter-config --from-literal=MONGO_CS=mongodb://mongo-0:27017,mongo-1:27017,mongo-2:27017/?replicaSet=test --dry-run=client -o yaml >>task22.yaml 


## Task 23 - counter app

Environment: your private cluster, namespace: counter
Create a new deployment called counter-v4. Use the same configuration as in task 22 with one exception.
This time mount a secret as a file. Use environment variable MONGO_CS_FILE to specify the location of the file.
Verify that it works.

Use previous deployment / service, add volume mount and configure secrets.

    k create secret generic secret-v4 --from-file=MONGO_CS=task23.txt -n counter --dry-run=client -o yaml >>task23.yaml


## Task 24 - secrets

Environment: your private cluster, namespace: web-servers
Create a new deployment. Call it app-t24v1, use image user4demo/training:app-v1.
The repository is password protected. Pass required credentials to Kubernetes:
    login: user4demo
    password: SecretPassword
    email: user4demo@kamilbaran.pl
Hints: hint 1

    docker login --username=user4demo --password=SecretPassword
    k create deployment app-t24v1 --image=user4demo/training:app-v1 -n web-servers --dry-run=client -o yaml >task24.yaml create secret generic  regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json  --type=kubernetes.io/dockerconfigjson -n web-servers >>task24.yaml

## Task 25 - scheduling

Environment: your private cluster, namespace: scheduling
Create a new deployment app-t25v1, use image kamilbaran/training:app-v1.
Use node selector to make sure pods will be running only on the computing nodes (based on labels created on task 10).

    k create ns scheduling 
    k create deployment app-t25v1 --image=kamilbaran/training:app-v1 -n scheduling --dry-run=client -o yaml > task25.yaml

Increase number of replicas, add NodeSelector section and verify.

    k get all --show-labels  -o wide
    k get no -L type

## Task 26 - scheduling

Environment: your private cluster, namespace: scheduling
Create a new deployment app-t26v1, use image kamilbaran/training:app-v1.
Use node affinity to make sure pods will be running only on the computing nodes (based on labels created on task 10).

Increase number of replicas, add affinity / nodeAffinity section to the pod spec and verify.

    k create deployment app-t26v1 --image=kamilbaran/training:app-v1 -n scheduling --dry-run=client -o yaml > task26.yaml

    affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: type
                operator: In
                values:
                - computing-node         

    k get all --show-labels  -o wide

## Task 27 - scheduling

Environment: your private cluster, namespace: scheduling
Create a new deployment app-t27v1, use image kamilbaran/training:app-v1.
Use pod anti-affinity to make sure that the scheduler will start just one pod on every worker node.
Verify that it works by scaling the deployment to 5 replicas.

Add podAntiAffinity section and udpate replicas:

    k create deployment app-t27v1 --image=kamilbaran/training:app-v1 -n scheduling --dry-run=client -o yaml > task27.yaml

    affinity:
        podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: app
                    operator: In
                    values:
                    - app-t27v1
                topologyKey: kubernetes.io/hostname

## Task 28 - scheduling

Environment: your private cluster, namespace: scheduling
Create a new deployment app-t28v1, use image kamilbaran/training:app-v1.
Use pod anti-affinity to make sure that the scheduler prefers nodes without pods of the same app. If the number of pods is higher than the number of nodes, the scheduler should start multiple pods on the same node.

    k create deployment app-t28v1 --image=kamilbaran/training:app-v1 -n scheduling --dry-run=client -o yaml > task28.yaml

    affinity
        podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
                podAffinityTerm:
                labelSelector:
                    matchExpressions:
                    - key: app
                        operator: In
                        values:
                        - app-t27v1
                topologyKey: kubernetes.io/hostname

## Task 29 - scheduling

Environment: your private cluster, namespace: counter
Update the mongo stateful set created in task 19. Choose one of scheduling options to make sure that all pods will be running on different nodes.

Check what is running in the `counter` namespace:

    k get deploy,sts,pod -n counter --show-labels -o wide

Update stateful set:

    cp task10.yaml task29.yaml

Add:

      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - mongo
            topologyKey: kubernetes.io/hostname

## Task 30 - resoueces

Environment: your private cluster, namespace: resources
Create new namespace resources.
Create a resource quota in this namespace to limit resource usage to 1 CPU, 1 GB of RAM and 10 pods.
Hints: hint 1

    k create ns resources
    k create quota namespace-limit --namespace=resources --dry-run=client -o yaml >task30.yaml

Add hard limits to the spec:

    hard:
        cpu: "1"
        memory: 1Gi
        pods: "10"


## Task 31 - resoueces

Environment: your private cluster, namespace: resources
Create new deployment app-t31v1, use image kamilbaran/training:app-v1.
Set a request and limit of 200m of CPU and 100MB of RAM.
Scale deployment to max possible number of pods that might be successfully started in this namespace.
Hints: hint 1

    k create deployment app-t31v1 --image=kamilbaran/training:app-v1 -n resources --dry-run=client -o yaml > task31.yaml

Add resources request / limit config and scale up (5 instances should be created):

    k scale deployment -n resources app-t31v1 --replicas=10

## Task 32 - resoueces

Environment: your private cluster, namespace: counter
Update the counter-v2 deployment created in task 21.
Set limit and request values of CPU to 10% of a single CPU.
Set limit and request values of RAM just above the lowest possible value that is needed to start the container.


    copy task21.yaml task32.yaml 

Update resource limits, apply till reach the lowest possible value that is needed to start the container. Test:

    k top pod -n counter 

## Task 33 - controllers

    Environment: your private cluster, namespace: controllers
    Create a job called job-at and run successfully just once.
    The job should execute the following command curl http://10.0.3.205:31386/?task=job-at&name=your-name.
    Put your real name instead of your-name in the request. Image kamilbaran/training:app contains curl command.


## Task 34 - controllers

    Environment: your private cluster, namespace: controllers
    Create a job called job-gp that will run ten times. Allow two jobs to be executed at the same time.
    Command: curl http://10.0.3.205:31386/?task=job-gp&name=your-name.
    Put your real name instead of your-name in the request. Image kamilbaran/training:app contains curl command.

## Task 35 - controllers

    Environment: your private cluster, namespace: controllers
    Create a job called job-cd that will run the following command every five minutes.
    Command: curl http://10.0.3.205:31386/?task=job-cd&name=your-name.
    Put your real name instead of your-name in the request. Image kamilbaran/training:app contains curl command.

## Task 36 - pod design

    Environment: your private cluster, namespace: default
    Create a standalone pod app-ps on the master node.
    The pod should execute the following command in the loop every 5 minutes curl http://10.0.3.205:31386/?task=app-ps&name=your-name.
    Put your real name instead of your-name in the request. Image kamilbaran/training:app contains curl command.

## Task 37 - pod design

    Environment: your private cluster, namespace: web-servers
    Create pod httpd-cs based on httpd:alpine image.
    The pod should have a read-only filesystem.
    Make sure that the pod is running.

## Task 38 - pod design

    Environment: your private cluster, namespace: web-servers
    Create pod httpd-dc based on httpd:alpine image.
    Drop all capabilities and add only required.
    Make sure that the pod is running.

## Task 39 - pod design

    Environment: your private cluster, namespace: web-servers
    Create pod tomcat-dc based on tomcat:jdk11-openjdk-slim image.
    Drop all capabilities and add only required.
    Make sure that the pod is running.

## Task 40 - cluster config, troubleshooting

    Environment: your private cluster
    Fix the problem with worker nodes.
    Please write an email to Kamil when you are ready to start this task.

## Task 41 - cluster config, troubleshooting

    Environment: your private cluster
    Fix the problem with the master node.
    Please write an email to Kamil when you are ready to start this task.

## Task 42 - observability, counter

    Environment: your private cluster, namespace: counter
    Update the counter-v2 deployment created in task 21.
    Add HTTP readiness and liveness check to make sure that the Counter app is working fine.

## Task 43 - observability, counter

    Environment: your private cluster, namespace: counter
    Update the mongo stateful set created in task 19.
    Force K8s to pull image every time the pod is recreated.
    Add readiness check that will verify that the Mongo is fully initialised (mongod status is primary or secondary).
    Use a script /data/readiness.sh directory. The first execution should be 5 seconds after starting the container and then run it it every 10 seconds.
    Reinitialise MongoDB if needed.

## Task 44 - security

    Environment: your private cluster, namespace: networking
    There is an app already running in your cluster in networking namespace.
    Familiarize yourself with the app and make sure you can connect to it.
    Create default-deny-all network policy that will drop all traffic.
    Create additional network policy that will allow all necessary traffic to make this app work again.
