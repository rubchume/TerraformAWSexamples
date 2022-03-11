#!/usr/bin/env bash

source output_variables.sh

scp -i $EC2_SSH_KEY_PEM_NAME $EC2_SSH_KEY_PEM_NAME hadoop@$MASTER_NODE_PUBLIC_DNS:/home/hadoop/
