#!/bin/bash
result=`mysql -u root -pnova -s -s -e 'use keystone; select T.id from token T join users U where U.name="test" and U.id=T.user_id;' `
echo $result
