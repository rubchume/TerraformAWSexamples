#!/usr/bin/env bash

source output_variables.sh

#https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-ssh-tunnel.html
ssh -i $EC2_SSH_KEY_PEM_NAME -N -D 8157 hadoop@$MASTER_NODE_PUBLIC_DNS
