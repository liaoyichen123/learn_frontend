#!/bin/bash
APP_NAME=react_calculator
TAG=latest
HOST_PORT=3030
CONTAINER_PORT=80

# Function to check if the port is in use
check_port_usage() {
  echo "Checking if port $HOST_PORT is in use..."
  lsof -i :$HOST_PORT
  if [ $? -eq 0 ]; then
    echo "Port $HOST_PORT is in use."
    return 0
  else
    echo "Port $HOST_PORT is free."
    return 1
  fi
}

# Check if a container with the same name exists
EXISTING_CONTAINER_ID=$(docker ps -a --filter "name=$APP_NAME" -q)

if [ -n "$EXISTING_CONTAINER_ID" ]; then
  echo "A container with the name $APP_NAME already exists. Container ID: $EXISTING_CONTAINER_ID"
  # Log container details
  docker ps -a --filter "id=$EXISTING_CONTAINER_ID"

  echo "Stopping and removing the existing container $EXISTING_CONTAINER_ID..."
  docker stop $EXISTING_CONTAINER_ID
  docker rm $EXISTING_CONTAINER_ID
fi

# Check if the port is in use by any process (Docker or non-Docker)
if check_port_usage; then
  echo "Checking if a Docker container is using the port..."
  PORT_CONTAINER_ID=$(docker ps --filter "publish=$HOST_PORT" -q)
  
  if [ -n "$PORT_CONTAINER_ID" ]; then
    echo "Found a running container using the port: $PORT_CONTAINER_ID"
    # Log container details
    docker ps --filter "id=$PORT_CONTAINER_ID"
    
    echo "Stopping and removing container $PORT_CONTAINER_ID..."
    docker stop $PORT_CONTAINER_ID
    docker rm $PORT_CONTAINER_ID
  else
    echo "The port is in use by another process. Here are the details:"
    lsof -i :$HOST_PORT
    echo "You need to manually stop the process using the port or choose a different port."
    exit 1
  fi
else
  echo "Port $HOST_PORT is not in use by any process."
fi

# Build the Docker image
echo "Building Docker image $APP_NAME:$TAG..."
docker build -t $APP_NAME:$TAG .

# Run the container
echo "Running Docker container $APP_NAME on port $HOST_PORT..."
docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $APP_NAME $APP_NAME:$TAG

# Check if the container started successfully
if [ $? -eq 0 ]; then
  echo "Container $APP_NAME is running successfully."
else
  echo "Failed to start the container. Please check the Docker logs for more information."
  exit 1
fi
