#!/usr/bin/env bash

docker build -t mymichu/azdo-setup .
docker run -it --rm \
  -w /work \
  -v $(pwd):/work \
  -e AZ_DEVOPS_AGENT_TOKEN  \
  -e AZ_DEVOPS_AGENT_URL \
  -t mymichu/azdo-setup \
  bash