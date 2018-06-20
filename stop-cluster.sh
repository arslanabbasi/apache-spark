#!/bin/bash

set -e
set -x
. ./env.sh

CONTAINER_IDS=$(docker ps -a -f "name=$MASTER_CTR" -f "name=$SLAVE_CTR" -q)

if [ -z "$CONTAINER_IDS" ];
then
  echo "No containers running"
  echo "Removing network $SPARK_NET"
  docker network rm $SPARK_NET > /dev/null
  exit 0
fi


echo "Stopping containers"
docker stop $CONTAINER_IDS > /dev/null
echo "Removing containers"
docker rm $CONTAINER_IDS > /dev/null
echo "Removing network $SPARK_NET"
docker network rm $SPARK_NET > /dev/null

