# apache-spark

# Docker-compose file to bring up 1 master and 1 worker node
  $ docker compose up -d
  
  $ docker compose up --scale worker=5 -d
  
  $ docker compose down


# Bash scripts to bring up a cluster of spark master/slaves nodes
  $ ./start-cluster.sh 5
  
  $ ./stop-cluster.sh
  
  $ ./test-client.sh 10
