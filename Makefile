.PHONY: all

container_tag?=latest

.ONESHELL:
include .env

local-build:
	docker-compose -f docker-compose-local.yml build
	docker-compose -f docker-compose-local.yml run api npm test
	docker-compose -f docker-compose-local.yml run web npm test

local-start:
	docker-compose -f docker-compose-local.yml up -d

local-stop:
	docker-compose -f docker-compose-local.yml down

local-push:
	docker login --username ${DOCKER_USERNAME} --password ${DOCKER_PASS}
	docker tag ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api:latest ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api:${TAG}
	docker tag ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web:latest ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web:${TAG}
	docker push ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-api
	docker push ${CI_REGISTRY}/${COMPOSE_PROJECT_NAME}-web

bootstrap-plan: 
	cd infra/terraform/bootstrap 
	terraform init
	terraform plan

bootstrap-apply: 
	cd infra/terraform/bootstrap 
	terraform plan
	terraform apply --auto-approve

bootstrap-destroy: 
	cd infra/terraform/bootstrap 
	terraform plan
	terraform destroy

toptal3tier-plan: 
	cd infra/terraform/toptal3tier 
	terraform init
	terraform plan

toptal3tier-apply: 
	cd infra/terraform/toptal3tier 
	terraform plan
	terraform apply --auto-approve

toptal3tier-deploy: 
	cd infra/terraform/toptal3tier 
	terraform plan -var container_tag="${container_tag}"
	terraform apply -var container_tag="${container_tag}" --auto-approve


toptal3tier-destroy: 
	cd infra/terraform/toptal3tier 
	terraform plan
	terraform destroy