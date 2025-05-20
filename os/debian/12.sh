#!/usr/bin/env -S bash -e -o pipefail

##### [ Enable Quad9 nameservers ] ########################################
cat << CONF > /etc/resolv.conf
search localhost

nameserver 9.9.9.9
nameserver 149.112.112.112
CONF

##### [ Update packages ] #################################################
apt update
apt dist-upgrade -y

##### [ WORKAROUND: stuck SSH connections ] ###############################
if [ ! -f /sys/class/tty/tty0/active ]; then
	sed -i '/^[^#].*pam_systemd.so/ s/^/# /' /etc/pam.d/common-session
	systemctl restart sshd
fi

##### [ Setup firewall ] ##################################################
apt install -y ufw
for SSH_ALLOW_IP_CIDR in "${SSH_ALLOW_IP_CIDRS[@]}"; do
	ufw allow from "${SSH_ALLOW_IP_CIDR}" to any port 22 proto tcp
done
ufw --force enable

##### [ Create new user ] #################################################
if [[ -n "${USER_NAME}" ]]; then
	echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | adduser "${USER_NAME}" --comment ""
	echo "${USER_NAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"
fi

##### [ Setup Docker ] ####################################################
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
OS_ARCHITECTURE="$(dpkg --print-architecture)"
OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
echo "deb [arch=${OS_ARCHITECTURE} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${OS_CODENAME} stable" \
	> /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker "${SUDO_USER}"
if [[ -n "${USER_NAME}" ]]; then
	usermod -aG docker "${USER_NAME}"
fi
cat << RULES >> /etc/ufw/after.rules

# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN
COMMIT
# END UFW AND DOCKER
RULES
ufw reload

##### [ Initialize swarm cluster ] ########################################
for SWARM_NODE_IP_CIDR in "${SWARM_NODE_IP_CIDRS[@]}"; do
	ufw allow from "${SWARM_NODE_IP_CIDR}" to any port 7946 proto tcp
	ufw allow from "${SWARM_NODE_IP_CIDR}" to any port 7946 proto udp
	ufw allow from "${SWARM_NODE_IP_CIDR}" to any port 4789 proto udp
	if [[ "${IS_MANAGER}" == "y" ]]; then
		ufw allow from "${SWARM_NODE_IP_CIDR}" to any port 2377 proto tcp
	fi
done
if [ -z "${SWARM_CLUSTER_JOIN_TOKEN}" ]; then
	IP_ADDRESS="$(hostname -I | awk '{ print $1 }')"
	docker swarm init --advertise-addr "${IP_ADDRESS}"
else
	docker swarm join --token "${SWARM_CLUSTER_JOIN_TOKEN}" "${SWARM_NODE_MANAGER_IP}:2377"
fi
if [[ "${IS_MANAGER}" == "y" ]]; then
	docker node update --availability drain "$(hostname)"
fi

##### [ Reboot system ] ###################################################
reboot
