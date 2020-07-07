## Build images (from docker-compose folder) and run them

    docker image build -t training:httpd httpd/
    docker image build -t training:mongo mongo/
    docker image ls 

Expected outcome:

    EPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
    training            mongo               15b8b37b65d7        5 seconds ago        124MB
    training            httpd               45ba13099c76        About a minute ago   19.1MB
    alpine              3.9                 78a2ce922f86        2 months ago         5.55MB

Run containers in detached state:

    docker run -d --name httpd --network host training:httpd
    docker run -d --name mongo --network host training:mongo
    docker ps -a 

Expected outcome:

    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
    90620778c98b        training:mongo      "/usr/bin/mongod --d…"   4 seconds ago       Up 2 seconds                            mongo
    9308e9e73ad7        training:httpd      "/usr/sbin/httpd -D …"   6 minutes ago       Up 6 minutes                            httpd

Next, test:

    curl localhost

Expected outcome:


    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>NobleProg Docker Training - main page</title>
    </head>
    <body>
        <p>main page</p>
        <p><a href="/next">next page</a></p>
        <p><a href="/phpinfo.php">php info</p>
        <p><a href="/mongo">MongoDB counter</a></p>
    </body>
    </html>

Check network interfaces:

    ip a 

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
        valid_lft forever preferred_lft forever
    2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 86:cd:d2:c8:6b:e7 brd ff:ff:ff:ff:ff:ff
        inet 10.0.3.193/24 brd 10.0.3.255 scope global dynamic noprefixroute ens18
        valid_lft 363sec preferred_lft 363sec
        inet6 fe80::2ef:ce32:7e8d:a5c9/64 scope link noprefixroute 
        valid_lft forever preferred_lft forever
    3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
        link/ether 02:42:18:00:79:72 brd ff:ff:ff:ff:ff:ff
        inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
        valid_lft forever preferred_lft forever
        inet6 fe80::42:18ff:fe00:7972/64 scope link 
        valid_lft forever preferred_lft forever

Clean-up: 

    docker rm -f mongo httpd

## Run images on bridge network

    docker run -d --name httpd --network test -p 80:80 --env MONGO_CS="mongodb://mongo:27017" training:httpd
    docker run -d --name mongo --network bridge training:mongo /usr/bin/mongod --bind_ip_all
    curl http://localhost/mongo/
    
Expected outcome (HTML):

    [..]
    Exception: No suitable servers found (`serverSelectionTryOnce` set): [Failed to resolve 'mongo']
    
Connection to Mongo won't work on bridge network, as there is not DNS name resolution. It will work in a user-defined network.
To see all differences, [check here](https://docs.docker.com/network/bridge/) 

## Run images on user defined network

    docker network create test
    docker run -d --name httpd --network test -p 80:80 --env MONGO_CS="mongodb://mongo:27017" training:httpd
    docker run -d --name mongo --network test training:mongo /usr/bin/mongod --bind_ip_all
    curl http://localhost/mongo/

Expected outcome (HTML):

    [..]
    I have been seen 1 times!!!<br />Response from: c8c8615286ff</p></body></html>

## Run images with mongo custom volume

    docker network create test
    docker run -d --name httpd --network test -p 80:80 -v mongo-data:/data/db --env MONGO_CS="mongodb://mongo:27017" training:httpd
    docker run -d --name mongo --network test training:mongo /usr/bin/mongod --bind_ip_all
    docker volume ls
    curl http://localhost/mongo/


## Kubernetes installation

Follow instructions from [here](https://training-course-material.com/training/Kubernetes_(KB))

## Kubernetes clean-up

    sudo su - 
    kubeadm reset
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

## Copy shared K8S cluster config 

scp 10.0.3.205:/home/student/.kube/config .