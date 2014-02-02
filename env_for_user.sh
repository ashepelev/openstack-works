#!/bin/bash

	

set_env()
{	
	

	echo "Getting pass..."
	usr_pass=`grep $user_name users | cut -d ":" -f2`;

	echo "Writing env file..."
	touch 	$usr_env_file
	echo "#!/usr/bin/env bash" > $usr_env_file;
	echo "HOST_IP=${HOST_IP:-195.208.252.81}" >> $usr_env_file
	HOST_IP=${HOST_IP:-195.208.252.81}
	echo "export NOVA_PROJECT_ID=$project_name" >> $usr_env_file
	echo "export TENANT=$project_name" >> $usr_env_file
	echo "export NOVA_USERNAME=$user_name" >> $usr_env_file
	NOVA_USERNAME=$user_name
	echo "export USERNAME=$user_name" >> $usr_env_file
	echo "export NOVA_API_KEY=${ADMIN_PASSWORD:-$usr_pass}" >> $usr_env_file
	NOVA_API_KEY=${ADMIN_PASSWORD:-$usr_pass}
	echo "export NOVA_URL=${NOVA_URL:-http://$HOST_IP:5000/v2.0/}" >> $usr_env_file
	NOVA_URL=${NOVA_URL:-http://$HOST_IP:5000/v2.0/}
	echo "export NOVA_VERSION=${NOVA_VERSION:-1.1}" >> $usr_env_file
	echo "export NOVA_REGION_NAME=${NOVA_REGION_NAME:-nova}" >> $usr_env_file
	echo "export EC2_URL=${EC2_URL:-http://$HOST_IP:80/services/Cloud}" >> $usr_env_file
	echo "export EC2_ACCESS_KEY=$user_name-cred" >> $usr_env_file
	echo "export EC2_SECRET_KEY=${ADMIN_PASSWORD:-$usr_pass}" >> $usr_env_file

	echo "export OS_AUTH_USER=$user_name" >> $usr_env_file
	echo "export OS_AUTH_KEY=$usr_pass" >> $usr_env_file
	echo "export OS_AUTH_TENANT=$project_name" >> $usr_env_file
	echo "export OS_AUTH_URL=$NOVA_URL" >> $usr_env_file
	echo "export NOVA_AUTH_STRATEGY=keystone" >> $usr_env_file
	NOVA_AUTH_STRATEGY=keystone
	echo "export OS_AUTH_STRATEGY=${NOVA_AUTH_STRATEGY:-keystone}" >> $usr_env_file
	
	good_tokens=`mysql -u root -pnova -sss -e "use keystone; select COUNT(TRUE) from token T join users U where T.user_id=U.id and U.name=\"$user_name\" and T.expires>CURDATE();"`	
	checkCommand=0
	if [ $good_tokens == 0 ] ;
	then
		checkCommand=`cat "./checkCommand"`
	else
	checkCommand=`mysql -u root -pnova -sss -e "use keystone; select max(T.id) from token T join users U where U.name=\"$user_name\" and U.id=T.user_id and T.expires=(select max(T.expires) from token T join users U where U.name=\"$user_name\" and U.id=T.user_id);"`
	fi
	echo "export AUTH_TOKEN=$checkCommand" >> $usr_env_file
	echo "export NOVA_KEY_DIR=/etc/mynova/creds/$project_name" >> $usr_env_file
	NOVA_KEY_DIR=/etc/mynova/creds/$project_name
	echo "export S3_URL=http://$NOVA_URL:3333" >> $usr_env_file
	
	echo "export EUCALYPTUS_CERT=/etc/mynova/creds/$project_name/$project_name.pem" >> $usr_env_file
	echo "export EC2_PRIVATE_KEY=$NOVA_KEY_DIR/pk.pem" >> $usr_env_file
	echo "export EC2_CERT=$NOVA_KEY_DIR/cert.pem" >> $usr_env_file
	echo "export NOVA_CERT=$NOVA_KEY_DIR/cacert.pem" >> $usr_env_file
	NOVA_CERT=$NOVA_KEY_DIR
	echo "export EUCALYPTUS_CERT=$NOVA_CERT" >> $usr_env_file

	credCount=`mysql -u root -pnova -sss -e "use keystone; select count(C.key) from credentials C join users U where C.user_id=U.id and U.name='$user_name'"` 
	if [ $credCount == 0 ] ;
	then
		/usr/local/bin/keystone-manage credentials add $user_name EC2 "$user_name-cred" $usr_pass $project_name
	fi
};

if [ -z $# ] ;
then
	echo "./env_for_user.sh user_name project_name"
	exit
fi

case $1 in
"help")
	echo "./env_for_user.sh user_name project_name"
;;
*)
	if [ $# -ne 2 ] ;
	then
		echo "./env_for_user.sh user_name project_name"
		exit
	else
		user_name=$1
		project_name=$2
		usr_env_file=/etc/mynova/env_files/$user_name\.sh
		set_env
	fi
;;
esac
