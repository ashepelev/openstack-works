#!/bin/bash

credCount=`mysql -u root -pnova -sss -e "use keystone; select count(C.key) from credentials C join users U where C.user_id=U.id and U.name='test'"` 
echo $credCount
if [ $credCount == 0 ] ;
then
	echo zero_results
else
	echo some_results
fi
