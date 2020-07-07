1. Deploy sample training-app and make sure there are no existing network policies

kubectl apply -f /home/student/training/training-app/training-app-base.yaml
kubectl get svc,deploy,pod,networkpolicy

2. Use wget to access deployed application from another container

kubectl run alpine -it --rm --image=alpine /bin/sh
wget --spider --timeout 1 training

3. Apply network policy that will allow connections to Training App only from pods labeled trusted=yes

kubectl apply -f /home/student/training/network-policy/training-network-policy.yaml

4. Try to access the application again, then change the label trusted=yes and try one more time

wget --spider --timeout 1 training
kubectl label pod --overwrite alpine-... trusted="yes"
wget --spider --timeout 1 training