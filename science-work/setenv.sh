#!/usr/bin/env bash
#
HOST_IP=195.208.252.79
export NOVA_PROJECT_ID=admin
export NOVA_USERNAME=admin
export NOVA_API_KEY=password
export NOVA_URL=http://$HOST_IP:80/keystone/v2.0/
export NOVA_VERSION=1.1
export NOVA_REGION_NAME=nova
export NOVA_AUTH_STRATEGY=keystone
export EC2_URL=http://$HOST_IP:80/services/Cloud
export EC2_ACCESS_KEY=admin
export EC2_SECRET_KEY=password

export OS_AUTH_USER=$NOVA_USERNAME
export OS_AUTH_KEY=$NOVA_API_KEY
export OS_AUTH_TENANT=$NOVA_PROJECT_ID
export OS_AUTH_URL=$NOVA_URL
export OS_AUTH_STRATEGY=$NOVA_AUTH_STRATEGY

export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_TENANT_NAME=admin
export OS_TENANT_ID=2410ff359da448318f77885220c3e143
export OS_REGION_NAME=RegionOne

