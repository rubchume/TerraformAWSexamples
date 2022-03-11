#!/usr/bin/env bash

source output_variables.sh

ssh -i $EC2_SSH_KEY_PEM_NAME hadoop@$MASTER_EC2_IP
