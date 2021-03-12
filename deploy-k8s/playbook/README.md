## Setup k8s multinode cluster on a KVM host

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

#### Run the playbook
~~~
$ ansible-playbook site.yml
~~~

#### Destroy the cluster (NOTE: This deletes the VMs as well)
~~~
$ ansible-playbook destroy.yml
~~~
