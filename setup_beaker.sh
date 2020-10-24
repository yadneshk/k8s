yum -y install libvirt qemu-kvm virt-manager virt-install libguestfs-tools libguestfs-xfs net-tools ipmitool vim tmux
systemctl restart libvirtd && systemctl enable libvirtd

cd /var/lib/libvirt
rm -rf images
mkdir /home/images
chcon -t virt_image_t /home/images
ln -s /home/images .

cd /home/images; wget http://file.pnq.redhat.com/~ykulkarn/deployment/rhosp13/kvm-images/rhel-server-7.8-x86_64-kvm.qcow2
virt-customize -a rhel-server-7.8-x86_64-kvm.qcow2 --root-password password:redhat --uninstall cloud-init
for i in {master-0,master-1,master-2,worker-0,worker-1}; do qemu-img create -f qcow2 $i.qcow2 60G; done
for i in {master-0,master-1,master-2,worker-0,worker-1}; do virt-resize --expand /dev/sda1 rhel-server-7.8-x86_64-kvm.qcow2 $i.qcow2; done
for i in {master-0,master-1,master-2,worker-0,worker-1}; do virt-install --ram 10240 --vcpus 4 --os-variant rhel7 --disk path=/home/images/$i.qcow2,device=disk,bus=virtio,format=qcow2 --import --noautoconsole --network network:default --vnc --name $i; done
for i in {master-0,master-1,master-2,worker-0,worker-1}; do virsh snapshot-create-as --name $i $i ; done

