#!/bin/bash
AWS_ACCOUNT_ID="635411703757"
AWS_ACCOUNT_REGION="us-east-1"
REPOSITORY_NAME="desafio/app"
IMAGE_VERSION="latest"
DOCKER_USERNAME="AWS"
APP_NAME="app"
TASK_DEFINITION="app"
CLUSTER_NAME="desafio"
COMMAND=$1

if [ "$COMMAND" == "apply" ]; then

    ##REQUIREMENTS
    apt-get install -y jq

    ##DEPLOY INFRA
    cd infra
    sudo terraform init
    sudo terraform apply -var-file="envs/desafio.tfvars" --auto-approve
    cd ..

    ##BUILD IMAGE
    sudo docker build -t $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION .

    ##PUSH IMAGE TO ECR
    PASSWORD=$(sudo aws ecr get-login-password)
    sudo docker login --username $DOCKER_USERNAME -p $PASSWORD $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
    sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION

    # ##UPDATE TASK DEFINITION IN ECS
    ECR_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_ACCOUNT_REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_VERSION"
    TASK_DEFINITION=$(sudo aws ecs describe-task-definition --task-definition $APP_NAME --region $AWS_ACCOUNT_REGION)
    NEW_TASK_DEFINTION=$(sudo echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
    NEW_TASK_INFO=$(sudo aws ecs register-task-definition --region "$AWS_ACCOUNT_REGION" --cli-input-json "${NEW_TASK_DEFINTION}")
    NEW_REVISION=$(sudo echo $NEW_TASK_INFO | jq '.taskDefinition.revision')
    OUTPUT=$(sudo aws ecs update-service --cluster $CLUSTER_NAME --service $APP_NAME --task-definition $APP_NAME:$NEW_REVISION --region $AWS_ACCOUNT_REGION)

elif [ "$COMMAND" == "destroy" ]; then
    cd infra
    sudo terraform destroy -var-file="envs/desafio.tfvars" --auto-approve
    cd ..

fi
