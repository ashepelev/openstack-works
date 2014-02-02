#!/bin/bash
source ./setenv.sh

images=( $(nova image-list | cut -d'|' -d' ' -f4 | grep '[a-z]' | grep -v kernel) )
param=""

for i in "${images[@]}"
do
	param=`echo $param FALSE $i`					
done

for i in "${ARR[@]}"
do
   echo "$i"
done

image=`zenity --list --radiolist \
	--title="Connecting VM" \
	--text="Choose the VM to connect" \
	--column="Mark" --column="Virtual Machine" \
	$param`
	

 if [ $? -eq "0" ]
 then
   image_id=`nova image-list | cut -d'|' -d' ' -f2,4 | grep -v kernel | grep $image | cut -d' ' -f1`
   boot_name=`echo $USER$(date +%H%M%S)`
   floating_ip=( $(nova floating-ip-create pub_pool | cut -d'|' -d' ' -f2 | grep [0-9]) )
   floating_ip=${floating_ip[0]}
   mkdir ~/.ssh/openstack
   ssh-keygen -f ~/.ssh/openstack/id_rsa -t rsa -N ''
   nova keypair-add --pub_key ~/.ssh/openstack/id_rsa.pub $boot_name
   nova boot --flavor 1 --image $image_id --security_groups default --key_name $boot_name $boot_name
   echo -n Launching
   while true; do
      if nova list | grep $boot_name | grep ACTIVE
      then 
         break
      else
      	 sleep 2
      	 echo -n .
      fi
   done	
   echo
   nova add-floating-ip $boot_name $floating_ip
   #vncviewer $floating_ip:0
   echo -n "connecting via ssh"
   while true; do
   		if ping -c 1 $floating_ip | grep ttl
   		then
   		   break
   		else
   		   sleep 2
   		   echo -n .
   		fi
   done
   ssh-keygen -f ~/.ssh/known_hosts -R $floating_ip
   if grep ubuntu $image
   then
	vncviewer $floating_ip:0
   elif grep windows $image
   then
	rdesktop $floating_ip
   else
	ssh -l root -i ~/.ssh/openstack/id_rsa $floating_ip
   fi
   nova keypair-delete $boot_name
   rm -r ~/.ssh/openstack
   nova remove-floating-ip $boot_name $floating_ip
   nova floating-ip-delete $floating_ip
   nova delete $boot_name
 else
   zenity --warning --title="Обычная работа" \
          --text="Обычная работа"
 fi
 
