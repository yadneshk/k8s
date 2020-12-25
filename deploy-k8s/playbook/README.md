## Setup k8s multinode cluster on a KVM host

#### Make sure to `ssh-copy-id` to the KVM host to have password less ssh to root user

#### Add the IP to your KVM host in the `inventory` file
~~~
$ cat inventory
[host]
10.19.xx.xx
~~~

#### Test whether your local system can reach to the KVM host via a ping test
~~~
$ ansible host -m ping
10.19.xx.xx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
~~~

#### Run the playbook
~~~
$ ansible-playbook playbook.yml
~~~
