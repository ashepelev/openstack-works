#!/bin/bash

user_name=$2
user_file=/etc/mynova/users

add_user()
{
	#echo $user_name >> keystone_tenants;
	stty -echo;
	read -p "Password: " passw; 
	echo;
	stty echo
	echo $user_name":"$passw >> $user_file;
#ADDING TO DATABASES NOVA
	/var/lib/nova/bin/nova-manage user create \
	--name=$user_name \
	#access and sercret params are optional
	--access=$passw \
	--secret=$passw \
	1>/etc/mynova/user_accounts/$user_name  \
	2>> /etc/mynova/log/user_adding.log;
#ADDING TO DATABASE KEYSTONE
	/usr/local/bin/keystone-manage user add \
	$user_name $passw;
#ADDING CREDS
	
};

delete_user()
{
	if  ! grep ^$user_name':' $user_file 1>/dev/null
	then
		echo "No Such User"
	else
	sed -i "/$user_name/d" $user_file;
	echo "Deleting from nova db...";	
	/var/lib/nova/bin/nova-manage user delete \
	--name=$user_name 2> /etc/mynova/log/user_deleting.log;
	echo "Deleting from keystone db...";
	/usr/local/bin/keystone-manage user disable $user_name
#DIRECT DELETE FROM DB
	#echo "delete from users where name='$user_name';" | \
	#	mysql -u root -pnova -D keystone;
	#rm /etc/mynova/user_account/$user_name
	fi
};

if [ -z $# ] ; then
	echo "./user_nova.sh {create|delete} user";
	exit;
fi
case $1 in
"create") 
	if [ $# -ne 2 ] ; then
		echo "./user_nova.sh {create|delete} user";
		exit
	else
		add_user
	fi
;;
"delete") 
	if [ $# -ne 2 ] ; then
		echo "./user_nova.sh {create|delete} user";
		exit
	else
		delete_user
	fi
;;
"help") echo "./user_nova.sh {create|delete} user"
;;
esac
