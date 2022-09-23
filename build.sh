#!/bin/bash

# Grab global variables
source vars

DOCKER=$(which docker)
BUILD_DATE=$(date -u '+%Y-%m-%dT%H:%M:%S%z')

# Build image according to Dockerfile
$DOCKER build --pull                               \
              --tag ${IMAGE_NAME}                  \
              --build-arg BUILD_DATE=${BUILD_DATE} \
              .

# Login to Gitlab Docker Registry (create ./login with your password - has to fit to $MAINTAINER)
cat ./login | docker login my.gitlab.com:12345 --username ${MAINTAINER} --password-stdin

# Re-tag image to assign it to the correct Gitlab repository
docker image tag ${IMAGE_NAME}:latest my.gitlab.com:12345/${IMAGE_NAME}:latest

# Push image to Docker Registry
docker image push my.gitlab.com:12345/${IMAGE_NAME}:latest