#!/usr/bin/env -S bash -e -o pipefail

##### [ Validate operating system ] #######################################
OS_ID="$(. /etc/os-release && echo "${ID}")"
if [[ "${OS_ID}" != debian ]]; then
	echo "Please run this script only on Debian operating system."
	exit 1
fi

##### [ Load environment variables ] ######################################
. .env

##### [ Validate required environment variables ] #########################
if [[ -z "${SSH_ALLOW_IP_CIDR}" ]]; then
	echo "\$SSH_ALLOW_IP_CIDR environment variable missing."
	exit 1
fi

##### [ Update packages ] #################################################
sudo apt update
sudo apt dist-upgrade -y

##### [ Setup firewall ] ##################################################
sudo apt install -y ufw
sudo ufw allow from "${SSH_ALLOW_IP_CIDR}" to any port 22 proto tcp
sudo ufw --force enable

##### [ Setup Docker ] ####################################################
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
OS_ARCHITECTURE="$(dpkg --print-architecture)"
OS_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
echo "deb [arch=${OS_ARCHITECTURE} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${OS_CODENAME} stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "${USER}"
cat << RULES | sudo tee -a /etc/ufw/after.rules > /dev/null

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
sudo ufw reload

##### [ Reboot system ] ####################################################
sudo reboot
