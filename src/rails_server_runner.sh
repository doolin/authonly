#!/bin/bash

# Build the Docker image
docker build -t rails_basic_auth_server -f Dockerfile.rails_basic_auth .

# Run the Docker container in detached mode
docker run -d \
  -p 9999:9999 \
  --name rails_basic_auth \
  rails_basic_auth_server
