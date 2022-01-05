#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo docker run -d \
--name dd-agent \
-p 8125:8125/udp \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
-e DD_API_KEY=${VarDdApiKey} \
-e DD_SITE="datadoghq.eu" ${VarDdImage}


