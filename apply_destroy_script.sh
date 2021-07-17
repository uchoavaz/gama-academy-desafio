#!/bin/bash

CMD=$(cat terraform_command)

if [ "$CMD" == "apply" ]
then

terraform apply -var-file="infra/envs/desafio.tfvars"

elif [ "$CMD" == "destroy" ]
then

terraform destroy -var-file="infra/envs/desafio.tfvars"

fi