# bootstrap-libvirt-vm-salt

Simple script for bootstrapping virtual machine in lbivirt+qemu environment

First args is hostname,
--vcup=8 to set vcpu's value
--mem=10 to set memmory size 10Gb
--vlan=99 to set vlan for your vm (see my SaltStack repo)
For example, if you want to create vm named my_virt_host_name whith 8 VCPU's and 4 GB RAM:

### Example

./bootstrap_vm.sh my_virt_host_name --vcpu=8 --mem=4 --vlan=99

more information about virt-build you can find at https://libguestfs.org/virt-builder.1.html
