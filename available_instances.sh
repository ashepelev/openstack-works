#!/bin/bash
images=`euca-describe-instances`
awk 'BEGIN {count=0; print "ID\tImage";} {count++; print count,"\t",$4} END {}' -f $images
