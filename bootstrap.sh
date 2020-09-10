#!/bin/bash
#It's a simple bootstrap script for libvirt

#Help function for some info
function help_func()
{
echo -e "\nIt's a bootstarp script. First args is hostname,\n
--vcup=8 to set vcpu's value\n
--mem=10 to set memmory size 10Gb\n
--vlan=99 to set vlan for your vm (see my SaltStack repo)\n
For example, if you want to create vm named my_virt_host_name whith 8 VCPU's and 4 GB RAM:\n
./bootstrap_vm.sh my_virt_host_name --vcpu=8 --mem=4 --vlan=99 \n"
exit 0
}

#Call help function 
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "?" ] || [[ $# -eq 0 ]]; then
	help_func
fi

#https://github.com/Guznin/bootstrap-libvirt-vm-salt
echo -e "\e[96m <====# WELCOME TO BOOTSTRAP! #====> \033[0m\n"

#Script arguents 
NAME=$1
FQDN="$NAME.domain.ru"
VCPU=${VCPU:-2}
MEM=${MEM:-1024} #Defaul value memmory in MB
DISKSIZE='10G'
VLAN=${VLAN:-1}
TEMPLATE='centos-7.8' #specify your OS 
IMAGESDIR='/var/lib/libvirt/images' #default in libvirt
FORMAT='qcow2' #you can change format for your disk
OUT_FILE="${IMAGESDIR}/${NAME}.${FORMAT}"
SALT_URL='https://salt.domain.ru:8811/signer' #SaltStack url for sign minion
SALT_TOKEN='MY SALT TOKEN' #your SALT token
CMD1=("curl -L https://bootstrap.saltstack.com | sh -s -- -A salt.domain.ru -i ${FQDN} stable 2019.2.5") #bootstrap minion
CMD2=("systemctl enable salt-minion") #enable minion
CMD3=("curl -k -sS -X POST -H 'SIGN-TOKEN: "${SALT_TOKEN}"' -d '{"\"nodes\"": ["\"${FQDN}\""]}' ${SALT_URL} ") #sign minion

#Parse arguments
while [ $# -gt 0 ]; do
   if [[ $2 == "--vcpu="* ]] || [[ $3 == "--mem="* ]] || [[ $4 == "--vlan"* ]] ; then
        declare VCPU="${2/--vcpu=/}"
        declare MEM=$(( ${3/--mem=/}*1024 ))
	declare VLAN="${4/--vlan=/}"
   fi
  shift
done

echo -e "\e[91m Make image \033[0m\n"

#Make image
virt-builder				\
	${TEMPLATE}				\
	--hostname	${FQDN}		\
	--output	${OUT_FILE}	\
	--format	${FORMAT}	\
	--timezone	UTC			\
	--network		    	\
	--firstboot-command "${CMD1} && ${CMD2} && ${CMD3}"

echo -e "\e[91m Create vm from image\033[0m\n"

#Create vm from image
virt-install											\
	--import											\
	--name ${NAME}										\
	--vcpus ${VCPU}										\
	--ram ${MEM}										\
	--disk path="${IMAGESDIR}/${NAME}.${FORMAT}"		\
	--cpuset=auto										\
	--os-type linux										\
	--autostart											\
	--noautoconsole										\
	--nographics										\
	--os-variant=centos7.0								\
	--network network=ovs-network,model=virtio,portgroup=internal_vlan-${VLAN}


if [ $? -ne 0 ]; then
    echo -e "\e[91m **** Error, something went wrong... **** \033[0m\n"
fi

echo -e "\e[32m ### Bootstrap ${FQDN} has been done ### \033[0m\n"

exit $?
