#!/usr/bin/python

import json
import argparse
from subprocess import Popen, PIPE

class ClusterNodesInventory(object):
    def __init__(self):
        self.inventory = {}
        self.inventory['all_nodes'] = {}
        self.inventory['all_nodes']['hosts'] = []
        self.inventory['all_nodes']['vars'] = {'ansible_ssh_pass':'password'}

        self.inventory['master'] = {}
        self.inventory['master']['hosts'] = []
        #self.inventory['master']['vars'] = {'ansible_ssh_pass':'password','ansible_user':'root'}

        self.inventory['worker'] = {}
        self.inventory['worker']['hosts'] = []
        #self.inventory['worker']['vars'] = {'ansible_ssh_pass':'password','ansible_user':'root'}

        self.read_cli_args()

        if self.parser_args.list:
            self.inventory = self.host_inventory()
        if self.parser_args.host:
            self.inventory = self.empty_inventory()

        print(json.dumps(self.inventory))

    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("--list", action="store_true")
        parser.add_argument("--host", action="store")
        self.parser_args = parser.parse_args()

    def host_inventory(self):
        pipe = Popen(['getent', 'hosts'], stdout=PIPE, universal_newlines=True)
        for line in pipe.stdout.readlines():
            host = line.split()[1]
            if host.startswith('master'):
                self.inventory['master']['hosts'].append(host)
                self.inventory['all_nodes']['hosts'].append(host)
            if host.startswith('worker'):
                self.inventory['worker']['hosts'].append(host)
                self.inventory['all_nodes']['hosts'].append(host)
        return self.inventory

    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

ClusterNodesInventory()
