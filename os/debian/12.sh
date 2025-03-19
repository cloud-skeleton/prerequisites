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
ufw allow from "${SSH_ALLOW_IP_CIDR}" to any port 22 proto tcp
ufw --force enable

##### [ Create new user ] #################################################
echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | adduser "${USER_NAME}" --comment ""
echo "${USER_NAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"

##### [ Setup Docker ] ####################################################
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
OS_ARCHITECTURE="$(dpkg --print-architecture)"
OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
echo "deb [arch=${OS_ARCHITECTURE} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${OS_CODENAME} stable" \
	> /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker "${USER_NAME}"
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

##### [ Reboot system ] ###################################################
reboot
