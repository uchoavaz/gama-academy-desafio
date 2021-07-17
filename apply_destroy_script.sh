#!/bin/bash

CMD=$(cat terraform_command)
cd infra
if [ "$CMD" == "apply" ]
then

terraform apply -var-file="envs/desafio.tfvars"

elif [ "$CMD" == "destroy" ]
then

terraform destroy -var-file="envs/desafio.tfvars"

fi