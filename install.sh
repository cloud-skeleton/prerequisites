#!/usr/bin/env -S bash -e -o pipefail

##### [ Validate operating system ] #######################################
OS_SCRIPT_FILE="$(. /etc/os-release && echo "os/${ID}/${VERSION_ID}.sh")"
if [ ! -f "${OS_SCRIPT_FILE}" ]; then
	echo "Please run this script only on supported operating system."
	exit 1
fi

##### [ Ask for required environment variables ] ##########################
while true; do
	read -erp "Enter name for new user: " USER_NAME
	if [[ -n "${USER_NAME}" ]]; then
		break
	fi
done
while true; do
	read -ersp "Enter password for new user: " USER_PASSWORD
	if [[ -n "${USER_PASSWORD}" ]]; then
		break
	fi
done
while true; do
	read -erp "Enter IP CIDRs for SSH connections: " -a SSH_ALLOW_IP_CIDRS
	if [[ -n "${SSH_ALLOW_IP_CIDRS}" ]]; then
		break
	fi
done

##### [ Run OS specific script file ] #####################################
. "${OS_SCRIPT_FILE}"
