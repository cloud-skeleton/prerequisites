#!/usr/bin/env python

from json import dumps
from os import getenv
from sys import exit, stderr
from typing import Any

def get_env(name: str) -> str:
    value: str | None = getenv(name)
    if not value:
        print(
            f"Error: environment variable '{name}' is not set or empty.",
            file = stderr
        )
        exit(1)
    return value


def get_hosts(name: str) -> list[str]:
    hosts: list[str] = get_env(name).split()
    return hosts


def main() -> None:
    inventory: dict[str, Any] = {
        "ingress_worker": {
            "hosts": get_hosts("NODE_INGRESS_WORKERS"),
            "vars": {
                "dns_nameservers": get_hosts("NODE_INGRESS_WORKERS_NAMESERVERS")
            }
        },
        "main_worker": {
            "hosts": get_hosts("NODE_MAIN_WORKERS"),
            "vars": {
                "dns_nameservers": get_hosts("NODE_MAIN_WORKERS_NAMESERVERS")
            }
        },
        "manager": {
            "hosts": get_hosts("NODE_MANAGERS"),
            "vars": {
                "dns_nameservers": get_hosts("NODE_MANAGERS_NAMESERVERS")
            }
        },
        "all": {
            "vars": {
                "ansible_ssh_private_key_file": get_env("SSH_KEY_FILE_PATH"),
                "ansible_user": get_env("SSH_USER"),
                "ssh_allow_ip_cidrs": get_hosts("SSH_ALLOW_IP_CIDRS")
            }
        },
        "_meta": {
            "hostvars": {}
        }
    }
    print(dumps(inventory))


if __name__ == "__main__":
    main()
