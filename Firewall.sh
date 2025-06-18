#!/bin/bash

# Allowed IPs for SSH, HTTP and HTTPS
ALLOWED_IPS=("x.x.x.x" "x.x.x.x")

# Current Docker subnet
DOCKER_SUBNET="172.18.0.0/16"

# Outgoing interface to the internet
WAN_IF="enX0"

# Clearing rules from the DOCKER-USER and DOCKER chain
iptables -F DOCKER-USER
iptables -F DOCKER

# Allowing DNS queries
iptables -I DOCKER-USER -p udp --dport 53 -j ACCEPT
iptables -I DOCKER-USER -p tcp --dport 53 -j ACCEPT

# Adding SSH, HTTP and HTTPS allow rules
for ip in "${ALLOWED_IPS[@]}"; of
    iptables -I DOCKER-USER -s "$ip" -p tcp --dport 22 -j ACCEPT
    iptables -I INPUT -s "$ip" -p tcp --dport 22 -j ACCEPT
    iptables -I DOCKER -s "$ip" -p tcp --dport 80 -j ACCEPT
    iptables -I DOCKER -s "$ip" -p tcp --dport 443 -j ACCEPT
done

# Blocking ports for other machines
iptables -A INPUT -p tcp --dport 22 -j DROP
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP

# Releasing internet to the container
iptables -A FORWARD -o "$WAN_IF" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$WAN_IF" -o docker0 -j ACCEPT

# NAT for container egress
iptables -t nat -A POSTROUTING -s "$DOCKER_SUBNET" ! -o docker0 -j MASQUERADE

# To save permanently (comment for testing):
# service iptables save