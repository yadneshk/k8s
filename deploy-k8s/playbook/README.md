## Setup k8s multinode cluster on a KVM host

### Requirements
- ansible == 2.9

#### Make sure to `ssh-copy-id` to the KVM host to have password less ssh to root user

#### Test whether ansible can execute commands on localhost as root user with a ping test
~~~
$ ansible host -m ping
localhost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
~~~

#### Encrypt Docker credentials (To avoid rate limiting)
```
$ cd k8s-cluster-deploy/deploy-k8s/playbook/
$ ansible-vault create ./vars/docker_creds.yml
```

#### Run the playbook
~~~
$ ansible-playbook site.yml --ask-vault-pass
~~~

#### Destroy the cluster (NOTE: This deletes the VMs as well)
~~~
$ ansible-playbook destroy.yml
~~~
