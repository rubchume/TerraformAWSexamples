#!/usr/bin/env bash

source output_variables.sh

FILE_TO_UPLOAD=$1

scp -i $EC2_SSH_KEY_PEM_NAME $FILE_TO_UPLOAD hadoop@$MASTER_NODE_PUBLIC_DNS:/home/hadoop/
