#!/usr/bin/python
import fcntl
import json
import socket
import struct

import fuelclient


def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])


def generate_rally_mos_nodes_tasks():
    nailgun_nodes_client = fuelclient.get_client('node')
    nailgun_nodes = nailgun_nodes_client.get_all()
    private_key = open("/root/.ssh/id_rsa", "r").read()

    nodes = []
    for nailgun_node in nailgun_nodes:
        node = {
            "address": nailgun_node["ip"],
            "hostname": nailgun_node["fqdn"],
            "username": "root",
            "private_key": private_key,
            "roles": nailgun_node["roles"]
        }
        nodes.append(node)

    nodes.append({
        "address": get_ip_address('eth0'),
        "hostname": socket.gethostname(),
        "username": "root",
        "password": "r00tme",
        "roles": ["master"]
    })

    return nodes


if __name__ == "__main__":
    nodes = generate_rally_mos_nodes_tasks()

    with open("nodes.json", "w") as f:
        f.write(json.dumps(nodes, indent=4))
        print "{0} generated".format(f.name)
