#!/usr/bin/env bash
set -x

echo "$DOCKER_PASS" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker tag ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api:latest ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api:${TRAVIS_COMMIT::6}
docker tag ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web:latest ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web:${TRAVIS_COMMIT::6}
docker push ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api
docker push ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web
