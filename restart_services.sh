#!/bin/sh


service nova-api restart
service nova-cert restart
service nova-compute restart
service nova-network restart
service nova-objectstore restart
service nova-scheduler restart
service nova-vncproxy restart
service nova-volume restart

