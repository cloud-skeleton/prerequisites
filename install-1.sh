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
if [[ -z "${USER_NAME}" ]]; then
	echo "\$USER_NAME environment variable missing."
	exit 1
fi
if [[ -z "${USER_PASSWORD}" ]]; then
	echo "\$USER_PASSWORD environment variable missing."
	exit 1
fi

##### [ Create new user ] #################################################
echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | adduser "${USER_NAME}" --comment ""
echo "${USER_NAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USER_NAME}"

##### [ WORKAROUND: stuck SSH connections ] ###############################
if [ ! -f /sys/class/tty/tty0/active ]; then
  sed -i '/^[^#].*pam_systemd.so/ s/^/# /' /etc/pam.d/common-session
  systemctl restart sshd
fi
