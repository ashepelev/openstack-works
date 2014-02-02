#!/bin/bash
project_name=$2
project_mngr=$3

project_file=/etc/mynova/project_file
user_file=/etc/mynova/users

add_project()
{
if ! grep ^$project_name':' $project_file 1>/dev/null
then
	echo $project_name':'$project_mngr >> $project_file
#ADDING PROJECT TO NOVA DATABASE
	echo "Adding to nova db...";
	/var/lib/nova/bin/nova-manage \
	project create \
	--project=$project_name \
	--user=$project_mngr \
	--desc="Project $project_name, owner: $project_mngr";
#ADDING PROJECT TO KEYSTONE DATABASE (TENANT)
	echo "Adding to keystone db...";
	/usr/local/bin/keystone-manage tenant add $project_name;
	/usr/local/bin/keystone-manage role grant \
	Admin $project_mngr $project_name;
#ADDING KEYPAIRS
	mkdir /etc/mynova/creds/$project_name
	euca-add-keypair $project_name > /etc/mynova/creds/$project_name/$project_name.pem
	chmod 600 /etc/mynova/creds/$project_name/$project_name.pem
#ADDING CREDS
	/var/lib/nova/bin/nova-manage project zipfile \ 
	--project=$project_name --user=$project_mngr \
	--file=/etc/mynova/creds/$project_name/$project_name.zip
	unzip /etc/mynova/creds/$project_name/$project_name.zip
	rm /etc/mynova/creds/$project_name/$project_name.zip
else
	echo "The Project is already exists!";
fi	
}

delete_project()
{
	if  ! grep ^$project_name':' $project_file 1>/dev/null
	then
		echo "No Such Project"
	else	
		sed -i "/$project_name/d" $project_file;	
	#DELETING FROM NOVA	
		echo "Deleting from nova db...";		
		/var/lib/nova/bin/nova-manage \
		project delete \
		--project=$project_name
	#DELETING FROM KEYSTONE
		echo "Deleting from keystone db...";
		/usr/local/bin/keystone-manage tenant disable $project_name;
		#echo "delete from tenants where name='$project_name';
		#	delete from credentials where " | \
		#	mysql -u root -pnova -D keystone;
	fi
}

if [ -z $# ] ; then
	echo "./project_nova.sh {create project_name project_mngr | delete project_name}"
	exit
fi
case $1 in
"create") 
	if [ $# -ne 3 ] ; then
		echo "./project_nova.sh {create project_name project_mngr | delete project_name}";
		exit;
	else
		add_project
	fi
;;
"delete") 
	if [ $# -ne 2 ] ; then
		echo "./project_nova.sh {create project_name project_mngr | delete project_name}";
		exit;
	else
		delete_project
	fi
;;
"help") echo "./project_nova.sh {create project_name project_mngr | delete project_name}";
;;
esac
