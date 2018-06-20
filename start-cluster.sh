#!/bin/bash

set -e
set -x

usage()
{
   echo "Usage: start-cluster.sh <num-slaves>"
   exit 1
}

if [ $# -lt 1 ]; then usage; fi

. ./env.sh

if [ -z $(docker network ls -f name=$SPARK_NET -q)  ]
then
  echo "Creating network $SPARK_NET"
  docker network create --label $SPARK_NET --internal $SPARK_NET  > /dev/null
fi

echo "Creating master node $MASTER_CTR"
docker run -d \
  --name $MASTER_CTR \
  -e _JAVA_OPTIONS="$MASTER_JVM_OPTS" \
  -e SPARK_MASTER_HOST=spark_master \
  -e SPARK_MASTER_PORT=$MASTER_PORT \
  -e SPARK_MASTER_WEBUI_PORT=$MASTER_WEBUI_PORT \
  --cpuset-cpus=$MASTER_CPUS \
  -m $MASTER_MEM \
  -p $MASTER_WEBUI_PORT:$MASTER_WEBUI_PORT \
  --net $SPARK_NET \
  $DOCKER_MASTER_IMAGE > /dev/null

#  -e SPARK_MASTER_HOST=$MASTER_CTR \

#MASTER_IP=$(docker inspect $MASTER_CTR|grep -i '"IPAddress": "172'|sed -e 's/^.* "//' -e 's/",$//')

echo "Creating $SLAVE_COUNT slave nodes concurrently"
for ((i=1; i<=$SLAVE_COUNT; i++))
do
  docker run -d \
    --name $SLAVE_CTR$i \
    -e _JAVA_OPTIONS="$SLAVE_JVM_OPTS" \
    -e MASTER_CTR=$MASTER_CTR \
    -e MASTER_PORT=$MASTER_PORT \
    -e SPARK_WORKER_WEBUI_PORT=$SLAVE_WEBUI_PORT \
    --cpuset-cpus=$SLAVE_CPUS \
    -m $SLAVE_MEM \
    -p $SLAVE_WEBUI_PORT \
    --net $SPARK_NET \
    $DOCKER_SLAVE_IMAGE > /dev/null
  sleep 1
done
exit 0

#echo "Waiting for slaves to come up..."
#while [ $(docker ps -f "name=$SLAVE_CTR" -q | wc -l) -lt $SLAVE_COUNT ]; do
#  sleep 2
#done

## Connecting Slaves to Master
#MASTER_IP=$(docker inspect $MASTER_CTR|grep -i '"IPAddress": "172'|sed -e 's/^.* "//' -e 's/",$//')
##docker exec -it spark-slave2 sh -c '/usr/local/spark-2.2.0-bin-hadoop2.7/sbin/start-slave.sh spark://172.17.0.2:7077
#for ((i=1; i<=$SLAVE_COUNT; i++))
#do
#  docker exec -it -d \
#    $SLAVE_CTR$i \
#    sh -c "/usr/local/spark-2.2.0-bin-hadoop2.7/sbin/start-slave.sh spark://$MASTER_IP:7077"
#  sleep 1
#done

echo "Cluster started!"
