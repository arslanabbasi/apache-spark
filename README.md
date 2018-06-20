# apache-spark

# Docker-compose file to bring up spark cluster
  $ docker compose up -d
  
  $ docker compose up --scale worker=5 -d
  
  $ docker compose down


# Bash scripts to bring up a cluster spark cluster
  $ ./start-cluster.sh 5
  
  $ ./stop-cluster.sh
  
  $ ./test-client.sh 10
