#!/bin/bash

if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "?" ]; then

	echo -e "\nIt's a bootstarp script. First args is hostname,\n
second argument is VCPU's cores, last arg is memory in GB\n
For example, if you want to create vm named my_virt_host_name whith 8 VCPU's and 4 GB RAM:\n
\e[33m./bootstrap_vm.sh my_virt_host_name 8 4 \033[0m"
	exit 0
fi

#https://github.com/Guznin/bootstrap-libvirt-vm-salt
echo -e "\e[96m <====# WELCOME TO BOOTSTRAP! #====> \033[0m\n"

FQDN="$1.domain.ru"
NAME=$1
VCPUS=$2
MEM_IN_GIG=$3
DISKSIZE='10G'
PORTGROUP='internal_vlan' # it's custom setting
TEMPLATE='centos-7.8'
IMAGESDIR='/var/lib/libvirt/images'
QCOW2="${IMAGESDIR}/${NAME}.qcow2"
MEMORY=$(( 1024*$3 ))
SALT_URL='https://salt.domain.ru:8811/signer'
SALT_TOKEN='YOUR SALT TOKEN'
CMD1=("curl -L https://bootstrap.saltstack.com | sh -s -- -A salt.domain.ru -i ${FQDN} stable 2019.2.5")
CMD2=("systemctl enable salt-minion")
CMD3=("curl -k -sS -X POST -H 'SIGN-TOKEN: "${SALT_TOKEN}"' -d '{"\"nodes\"": ["\"${FQDN}\""]}' ${SALT_URL} ")

echo -e "\e[91m Make image \033[0m\n"

#Make image
virt-builder				\
	${TEMPLATE}			\
	--hostname	${FQDN}		\
	--output	${QCOW2}	\
	--format	qcow2		\
	--timezone	UTC		\
	--network		    	\
	--firstboot-command "${CMD1} && ${CMD2} && ${CMD3}"

echo -e "\e[91m Create vm from image\033[0m\n"

#Create vm from image
virt-install									\
	--import								\
	--name ${NAME}								\
	--vcpus ${VCPUS}							\
	--ram ${MEMORY}								\
	--disk path="${IMAGESDIR}/${NAME}.qcow2"				\
	--cpuset=auto								\
	--os-type linux								\
	--autostart								\
	--noautoconsole								\
	--nographics								\
	--os-variant=centos7.0							\
	--network network=default,model=virtio,portgroup=${PORTGROUP}


if [ $? -ne 0 ]; then
    echo -e "\e[91m **** Error, something went wrong... **** \033[0m\n"
fi

echo -e "\e[32m ### Bootstrap ${FQDN} has been done ### \033[0m\n"

exit $?
