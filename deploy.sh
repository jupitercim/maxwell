#!/bin/bash
set -x

region=ap-northeast-1
cluster="arn:aws:ecs:ap-northeast-1:462475635429:cluster/tk-qa1-bigdata-ecs-cluster"

echo "[INFO]: Register task definition"
aws ecs register-task-definition --family bin-qa-bdp-maxwell-card --cli-input-json file://./task-definition.json --region ${region}

echo "[INFO]: Update or create ecs service"
services=`aws ecs describe-services --services bin-qa-bdp-maxwell-card --cluster ${cluster} --region ${region} | jq .failures[]`
revision=`aws ecs describe-task-definition --task-definition bin-qa-bdp-maxwell-card --region ${region} | jq .taskDefinition.revision`
checkservicestatus=`aws ecs describe-services --services bin-qa-bdp-maxwell-card --cluster ${cluster} --region ${region} | jq .services[0].status | tr -d '"'`

if [ "$services" == "" ]; then
  checkservicestatus=`aws ecs describe-services --services bin-qa-bdp-maxwell-card --cluster ${cluster} --region ${region} | jq .services[0].status | tr -d '"'`
  if [ "$checkservicestatus" == "INACTIVE" ]; then
    aws ecs create-service --service-name bin-qa-bdp-maxwell-card --launch-type FARGATE --cli-input-json file://./service-definition.json --region ${region}
    echo "[INFO]: Service is active" 
  fi
  echo "[INFO]: Entered existing service"
  desired_count=`aws ecs describe-services --services bin-qa-bdp-maxwell-card --cluster ${cluster} --region ${region} | jq .services[].desiredCount`
  if [ ${desired_count} = "0" ]; then
    desired_count="1"
  fi
  aws ecs update-service --cluster ${cluster} --region ${region} --service bin-qa-bdp-maxwell-card --task-definition bin-qa-bdp-maxwell-card:${revision} --desired-count ${desired_count} --deployment-configuration maximumPercent=100,minimumHealthyPercent=0  --force-new-deployment
else
  echo "[INFO]: Entered new service"
   aws ecs create-service --service-name bin-qa-bdp-maxwell-card --launch-type FARGATE --cli-input-json file://./service-definition.json --region ${region}
fi