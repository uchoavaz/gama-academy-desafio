#This project consists of deploying the proposed application in the challenge of the Gama Academy in AWS in an automated way.

Requirements
------------
- Git >= v2.25.1
- 2 AWS's account(Prod and Dev) with permissions: Create ALB, Create Target Group, Create ALB Listeners, Create/Update Cluster, Task definition and Services, Create/Update Cloudwatch logs, Create IAM Role, Create Ec2 security groups, Create Cloudwatch metric alarms, Create appautoscaling policy

How the deploy works
------------
This deploy consists of using Github actions for an automated deploy of the application in Node.js in the ECS service with Fargate, from AWS. The workflow consists in:
  1. Set Aws Credentials in Github
  2. Deploy the application only setting apply or destroy and pushing the commit to the dev branch(dev environment) or master branch (prod environment).
  3. Check for the CI/CD treadmill
  4. Use the application

GitHub Set credentials
------------

In https://github.com/uchoavaz/gama-academy-desafio/settings/secrets/actions set 4 repository secrets:acces
- AWS_ACCESS_KEY_ID_DEV
- AWS_SECRET_ACCESS_KEY_DEV
- AWS_ACCESS_KEY_ID_PROD
- AWS_SECRET_ACCESS_KEY_PROD

** To create Access Key and Secret Access Key go to https://console.aws.amazon.com/iam/home#/users/<user_name> > Security Credentials > Access Key > Create Access Key


DEPLOY
------------

- To apply application in Prod:
 
      git checkout master
      change the content inside the file terraform_ci_state/terraform_command_prod to "apply" (to apply the entire infra and application)
      git add .
      git commit -m "<describre the commit here>"
      git push origin prod
 
- To destroy application in Prod:
 
      git checkout master
      change the content inside the file terraform_ci_state/terraform_command_prod to "destroy" (to destroy the entire infra and application)
      git add .
      git commit -m "<describre the commit here>"
      git push origin prod

- To apply application in Dev:
 
      git checkout dev
      change the content inside the file terraform_ci_state/terraform_command_dev to "apply" (to apply the entire infra and application)
      git add .
      git commit -m "<describre the commit here>"
      git push origin dev    
 
- To destroy application in Dev:
 
      git checkout dev
      change the content inside the file terraform_ci_state/terraform_command_dev to "destroy" (to destroy the entire infra and application)
      git add .
      git commit -m "<describre the commit here>"
      git push origin dev


Check Deploy Status
------------
  1. Go to https://github.com/uchoavaz/gama-academy-desafio/actions and click in the workflow with the commit made in the last task
  2. For the deploy(Apply) to have completed successfully, the 3 jobs must have been successfully completed. (Deploy/Destroy AWS Infra <Dev or Prod>, Push image to ECR and Deploy app to ECS)
  3. For the deploy(Destroy) to have completed successfully, only the first job(Deploy/Destroy AWS Infra <Dev or Prod>) must have been successfully.

  
CI/CD Workflow
------------

- **Deploy/Destroy AWS Infra (Dev or Prod)**: Este job é destinado ao deploy da infraestrutura do ECS + ALB + Cloudwatch Alarms and Logs + Auto Scale + Permissive Roles and Policies pelo Terraform
- **Push image to ECR**: Este job é destinado a gerar o build da imagem do Docker e realizar o push deste para o ECR
- **Deploy app to ECS**: This job is intended to update the task definition to ECS so that tasks start running with the last image inserted in the ECR
  
App Logs
------------
Container/application exception logs are located in cloudwatch logs. Follow the access link.
  
Resource Monitoring
------------
As métricas de utilização dos recursos das máquinas do Fargate estão localizadas no Cloudwatch. Segue o link.
