# bootstrap-libvirt-vm-salt
Simple script for bootstrapping virtual machine in lbivirt+qemu environment

It's a bootstarp script. First argument is a hostname, second argument is VCPU's cores, last argument is a memory in GB. For example, if you want to create vm named "my_virt_host_name" whith 8 VCPU's and 4 GB RAM:

./bootstrap_vm.sh my_virt_host_name 8 4
