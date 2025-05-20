#!/usr/bin/env -S bash -e -o pipefail

##### [ Validate operating system ] #######################################
OS_SCRIPT_FILE="$(. /etc/os-release && echo "os/${ID}/${VERSION_ID}.sh")"
if [ ! -f "${OS_SCRIPT_FILE}" ]; then
	echo "Please run this script only on supported operating system."
	exit 1
fi

##### [ Ask for required environment variables ] ##########################
read -erp "Enter name for new user (or leave blank to use current one): " USER_NAME
if [[ -n "${USER_NAME}" ]]; then
	while true; do
		read -ersp "Enter password for new user: " USER_PASSWORD
		if [[ -n "${USER_PASSWORD}" ]]; then
			break
		fi
	done
fi
while true; do
	read -erp "Enter IP CIDRs for SSH connections: " -a SSH_ALLOW_IP_CIDRS
	if [[ -n "${SSH_ALLOW_IP_CIDRS}" ]]; then
		break
	fi
done
while true; do
	read -erp "Is this going to be a manager node? (y/n): " IS_MANAGER
	if [[ "${IS_MANAGER}" == "y" || "${IS_MANAGER}" == "n" ]]; then
		break
	fi
done
while true; do
	read -erp "Enter cluster join token (or leave blank to initialize): " SWARM_CLUSTER_JOIN_TOKEN
	if [[ ${SWARM_CLUSTER_JOIN_TOKEN} =~ ^(SWMTKN-1-[a-z0-9]{64,}-[a-z0-9]{32,})?$ ]]; then
		break
	fi
done
if [ -n "${SWARM_CLUSTER_JOIN_TOKEN}" ]; then
	while true; do
		read -erp "Enter IP address of any cluster manager node: " SWARM_NODE_MANAGER_IP
		if [[ -n "${SWARM_NODE_MANAGER_IP}" ]]; then
			break
		fi
	done
fi
while true; do
	read -erp "Enter IP CIDRs of other cluster nodes: " -a SWARM_NODE_IP_CIDRS
	if [[ -n "${SWARM_NODE_IP_CIDRS}" ]]; then
		break
	fi
done

##### [ Run OS specific script file ] #####################################
. "${OS_SCRIPT_FILE}"
