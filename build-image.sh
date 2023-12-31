#!/usr/bin/env bash

/snap/bin/lxc launch ubuntu-daily:jammy runner --vm
while ! /snap/bin/lxc exec runner -- /usr/bin/who
do
    echo "Wait for lxd agent to be ready"
    sleep 10
done
while ! /snap/bin/lxc exec runner -- /usr/bin/nslookup github.com
do
    echo "Wait for network to be ready"
    sleep 10
done

/snap/bin/lxc exec runner -- /usr/bin/apt-get update
/snap/bin/lxc exec runner --env DEBIAN_FRONTEND=noninteractive -- /usr/bin/apt-get upgrade -yq
/snap/bin/lxc exec runner --env DEBIAN_FRONTEND=noninteractive -- /usr/bin/apt-get install linux-generic-hwe-22.04 -yq

/snap/bin/lxc restart runner
while ! /snap/bin/lxc exec runner -- /usr/bin/who
do
    echo "Wait for lxd agent to be ready"
    sleep 10
done
while ! /snap/bin/lxc exec runner -- /usr/bin/nslookup github.com
do
    echo "Wait for network to be ready"
    sleep 10
done

/snap/bin/lxc exec runner -- /usr/bin/apt-get update
/snap/bin/lxc exec runner --env DEBIAN_FRONTEND=noninteractive -- /usr/bin/apt-get upgrade -yq
/snap/bin/lxc exec runner --env DEBIAN_FRONTEND=noninteractive -- /usr/bin/apt-get install docker.io npm python3-pip shellcheck jq wget -yq
/snap/bin/lxc exec runner -- /usr/sbin/groupadd microk8s
/snap/bin/lxc exec runner -- /usr/sbin/usermod -aG microk8s ubuntu
/snap/bin/lxc exec runner -- /usr/sbin/usermod -aG docker ubuntu
/snap/bin/lxc exec runner -- /usr/sbin/iptables -I DOCKER-USER -j ACCEPT

/snap/bin/lxc publish runner --alias runner --reuse -f
/snap/bin/lxc image export runner ./runner-image --vm
