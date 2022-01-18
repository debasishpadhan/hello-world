pipeline {
    agent { node { label 'agent1' } }
    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_DEFAULT_REGION = "ap-south-1" 
        IMAGE_REPO_NAME = "hello-docker"
        IMAGE_TAG = "latest"
        //CONTAINER_PORT = "80:80"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        NOTIFY_EVENT_TOKEN = credentials('notify-token')
    }
   
    stages {
        stage('Logging into AWS ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout scm     
            }
        }

        stage('Building image') {
            steps {
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Built approve notification') {
            options { timeout(time: 2, unit: 'MINUTES') }
            steps {
                script {
                    notifyEvents message: "Please <a href='${BUILD_URL}/input'>click here</a> to go to console output of build-id ${BUILD_ID} to approve or Reject.", token: "${NOTIFY_EVENT_TOKEN}"
                    userInput = input submitter: '', message: "Do you approve the Build-${BUILD_TAG} ?"
                    //env.node_name = input id: 'Agent', message: "Do you approve the Build-${BUILD_TAG} ?", submitter: 'admin', parameters: [choice(choices: ['agent1', 'agent2'], description: 'Which production machine?', name: 'agentSelect')]
                }
            }
        }

        stage('Pushing to ECR') {
            steps {  
                script {
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:version${env.BUILD_NUMBER}"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:version${env.BUILD_NUMBER}"
                }
            }
        }

        stage('ECS Cluster,Task,Service Creation') {
            agent { label "master" }
            steps {  
                script {
                    sh "aws ecs create-cluster --cluster-name fargate-cluster && sleep 3m"
                    sh "sed 's/version*/version${env.BUILD_NUMBER}/' task-definition.json"
                    sh "aws ecs register-task-definition --cli-input-json file://$HOME/task-definition.json"
                    sh "aws ecs create-service --cluster fargate-cluster --service-name fargate-service --task-definition ${IMAGE_REPO_NAME}:4 --desired-count 1 --launch-type 'FARGATE' --network-configuration 'awsvpcConfiguration={subnets=[subnet-0bba38ef988e68656,subnet-0d5fb5b19d05062b9],securityGroups=[sg-00deb8fbfc3520975],assignPublicIp=ENABLED}'"
                    sh "aws ecs list-services --cluster fargate-cluster"
                    //sh "sleep 10m"
                    //sh "aws ecs delete-service --cluster fargate-cluster --service fargate-service --force"
                    //sh "aws ecs delete-cluster --cluster fargate-cluster"
                }
            }
        }

        stage('Skype Notification') {
            steps {
                script {
                    notifyEvents message: 'Cluster is Up and Running', token: "${NOTIFY_EVENT_TOKEN}"
                }
            }
        }

        /*stage('Skype Notification') {
            steps {
                script {
                    //sh "echo Notification Sent"
                    notifyEvents message: '$BUILD_TAG | Built successfully', token: "${NOTIFY_EVENT_TOKEN}"
                }
            }
        }

        stage('Deploy to Machine') {
            agent { label "${env.node_name}" }
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:version${env.BUILD_NUMBER}"
                    sh "docker ps -q --filter 'name=${IMAGE_REPO_NAME}' | grep -q . && docker kill ${IMAGE_REPO_NAME} || echo No running ${IMAGE_REPO_NAME} containers"
                    sh "sleep 10"
                    sh "docker run --rm --name ${IMAGE_REPO_NAME} -d -p ${CONTAINER_PORT} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:version${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Container Notification') {
            steps {
                script {
                    notifyEvents message: "${IMAGE_REPO_NAME} Conrainer is up and running", token: "${NOTIFY_EVENT_TOKEN}"
                }
            }
        }*/
    }
}
