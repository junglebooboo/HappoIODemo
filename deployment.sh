# !/bin/bash
set -e
echo "Deploying to ${DEPLOYMENT_ENVIRONMENT}"
echo $ACCOUNT_KEY_STAGING > service_key.txt
base64 -i service_key.txt -d > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account ${ACCOUNT_ID} --key-file ${HOME}/gcloud-service-key.json
gcloud config set project $PROJECT_ID
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud config set compute/zone $CLOUDSDK_COMPUTE_ZONE
gcloud --quiet container clusters get-credentials $CLUSTER_NAME
# SKIP REBUILDING DOCKER IMAGE IN EVERY BUILD: 
docker build -t eu.gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1 .
gcloud docker -- push eu.gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1
kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=eu.gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1
echo " Successfully deployed to ${DEPLOYMENT_ENVIRONMENT}"