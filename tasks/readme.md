## CKA and CKAD sample exam tasks part 1

### Task 1
Environment: your private cluster
Create namespace called: web-servers
Start Nginx web server in a single pod called app-nginx-118. Use the official 1.18 image based on the Alpine Linux.

### Task 2
Environment: your private cluster, namespace: web-servers
Create a new deployment called nginx-t2v1. Use the latest Nginx image based on the Alpine.
Scale this deployment to 3 replicas and expose it by a service type with the same name on port 30082 on all the nodes.

### Task 3
Environment: your private cluster
List all the pods from a kube-system namespace sorted by the node name.
Write the output into /home/student/training/tasks/task-3.txt on your desktop machine. The output should include the node name and can't be modified manually.

### Task 4
Environment: your private cluster
List all your pods from all namespaces with the CPU and memory current consumption. Sort the list descending by the memory column.
Write the output into /home/student/training/tasks/task-4-iIlLo0O.txt on your desktop machine.

### Task 5
Environment: shared cluster
Create a config map in the default namespace.
The name of the config map should be your name.
It should contain the following keys: number, colour, brand, month. The values should correspond to the keys, but you can choose whatever you like.

### Task 6
Environment: shared cluster
List all pods that have the tier label set to control-plane value.
Write the output into /home/student/training/tasks/task-6-h43kj2a2.txt on your desktop machine.

### Task 7
Environment: your private cluster, namespace: web-servers
Create config map called nginx-ex7-data. It should contain index.html file that is located here
Create deployment nginx-t7v1 that will use this config map to overwrite the default index.html file.
Create service nginx-t7v1 that will expose this app on port 30087.

### Task 8
Environment: your private cluster
Play with any other web server. You can use any image you like but do not use Nginx.
You can use any namespace, any controller, any way of exposing it.
Add a label task of value eight to all resources that you will create during this task.
