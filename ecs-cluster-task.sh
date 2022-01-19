#aws ecs create-cluster --cluster-name fargate-cluster
aws ecs register-task-definition --cli-input-json file://task-definition.json

#aws ecs list-task-definitions | grep hello-docker
REVISION=`aws ecs describe-task-definition --task-definition hello-docker | jq .taskDefinition.revision`

aws ecs create-service --cluster fargate-cluster --service-name fargate-service --task-definition hello-docker:$REVISION --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-0bba38ef988e68656,subnet-0d5fb5b19d05062b9],securityGroups=[sg-00deb8fbfc3520975],assignPublicIp=ENABLED}"
#aws ecs list-services --cluster fargate-cluster

#aws ecs delete-service --cluster fargate-cluster --service fargate-service --force
#aws ecs delete-cluster --cluster fargate-cluster
