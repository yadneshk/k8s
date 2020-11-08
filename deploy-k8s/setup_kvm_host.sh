MASTER=3
WORKER=2
RHEL7_IMAGE = 'http://file.pnq.redhat.com/~ykulkarn/deployment/rhosp13/kvm-images/rhel-server-7.8-x86_64-kvm.qcow2'

yum -y install libvirt qemu-kvm virt-manager virt-install libguestfs-tools libguestfs-xfs net-tools ipmitool vim tmux
systemctl restart libvirtd && systemctl enable libvirtd

cd /var/lib/libvirt
rm -rf images
mkdir /home/images
chcon -t virt_image_t /home/images
ln -s /home/images .

cd /home/images
wget $RHEL7_IMAGE

virt-customize -a rhel-server-7.8-x86_64-kvm.qcow2 --root-password password:redhat --uninstall cloud-init

for (( i=0;i<$MASTER;i++))
do
  qemu-img create -f qcow2 master-$i.qcow2 60G
  virt-resize --expand /dev/sda1 rhel-server-7.8-x86_64-kvm.qcow2 master-$i.qcow2
  virt-install --ram 10240 --vcpus 4 --os-variant rhel7 --disk path=/home/images/master-$i.qcow2,device=disk,bus=virtio,format=qcow2 --import --noautoconsole --network network:default --vnc --name master-$i
done

for (( i=0;i<$WORKER;i++))
do
  qemu-img create -f qcow2 worker-$i.qcow2 60G
  virt-resize --expand /dev/sda1 rhel-server-7.8-x86_64-kvm.qcow2 worker-$i.qcow2
  virt-install --ram 10240 --vcpus 4 --os-variant rhel7 --disk path=/home/images/worker-$i.qcow2,device=disk,bus=virtio,format=qcow2 --import --noautoconsole --network network:default --vnc --name worker-$i
done
