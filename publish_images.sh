#!/bin/bash

pub_im()
{
	if [ $image_path -neq *.tar.gz ] ;
	then
		echo "Supported images in archives with *-vmlinuz, *-initrd, *.img files"
		exit
	fi
	
	SERVICE_TOKEN=`mysql -u root -pnova -s -s -e "use keystone; select max(T.id) from token T join users U where U.name=\"$admin_name\" and U.id=T.user_id and T.expires=(select max(T.expires) from token T join users U where U.name=\"$admin_name\" and U.id=T.user_id);"`
	IMAGE_NAME=`basename $image_path`

#	if [ $2 == *.iso ] ;
#	then
#		$IMAGE_NAME=${IMAGE_NAME}.iso
#	elif [ $2 == *.img ] 
#		$IMAGE_NAME=${IMAGE_NAME}.img
#	else
#		echo "Supported iso, img"
#	fi


	echo "Image will be copied to /etc/mynova/images dir"
	mkdir /etc/mynova/images/$new_image_name/
	#cp $image_path /etc/mynova/images/$new_image_name/
	tar -zxf $image_path  -C /etc/mynova/images/$new_image_name
	echo "uploading kernel..."
	RVAL=`glance --auth_token=$SERVICE_TOKEN add name=$new_image_name-kernel is_public=true container_format=aki disk_format=aki < /etc/mynova/images/$new_image_name/*-vmlinuz`
	KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`#
	echo "uploading ramdisk..."
	glance --auth_token=$SERVICE_TOKEN add name="$new_image_name-ramdisk" kernel_id=$KERNEL_ID is_public=true container_format=ari disk_format=ari  < /etc/mynova/images/$new_image_name/*-initrd
	echo "uploading image..."
	glance --auth_token=$SERVICE_TOKEN  add name="$new_image_name" kernel_id=$KERNEL_ID is_public=true container_format=ami disk_format=ami  < /etc/mynova/images/$new_image_name/*.img
};


if [ -z $# ] ;
then
	echo "./publish_images.sh admin_name image_path image_name"
	exit
fi

case $1 in
"help")
	echo "./publish_images.sh admin_name image_path image_name"
;;
*)
	if [ $# -ne 3 ] ;
	then
		echo "./publish_images.sh admin_name image_path image_name"
		exit
	else
		admin_name=$1
		image_path=$2
		new_image_name=$3
		pub_im
	fi
;;
esac
