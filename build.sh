#!/bin/bash
set -x

timestamp=$1

region=ap-northeast-1

echo "[INFO]: Build docker image"
docker build -t bin_qa_bdp_maxwell_card_repo:latest .

echo "[INFO]: Tag docker image"
docker tag bin_qa_bdp_maxwell_card_repo:latest 462475635429.dkr.ecr.ap-northeast-1.amazonaws.com/bin_qa_bdp_maxwell_card_repo:latest

echo "[INFO]: Authenticate Docker client..."
$(aws ecr get-login  --no-include-email --region ${region})

echo "[INFO]: Push the image to AWS repository"
aws ecr describe-repositories  --repository-names bin_qa_bdp_maxwell_card_repo --region ${region} || aws ecr create-repository --repository-name bin_qa_bdp_maxwell_card_repo --region ${region}
aws ecr describe-repositories  --repository-names bin_qa_bdp_maxwell_card_repo --region ${region} && docker push 462475635429.dkr.ecr.ap-northeast-1.amazonaws.com/bin_qa_bdp_maxwell_card_repo:latest

echo "[INFO]: upload image to ecr successfully..."

echo "[INFO]: Update task-definition.json"
sed -i "s|\"image\": \".*\"|\"image\": \"462475635429.dkr.ecr.ap-northeast-1.amazonaws.com/bin_qa_bdp_maxwell_card_repo:latest\"|g" ./task-definition.json
