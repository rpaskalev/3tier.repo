# Sample 3tier app
This repository contains code for a [Node.js multi-tier application ](https://git.toptal.com/namikp/node-3tier-app) and supporting infrastructure automation to make it deployable in AWS fargate

## Local development
### Prerequisites
In order to prepare a local machine for development, one needs to have the following installed and configured:

* [Docker](https://www.docker.com/get-started)
* [Docker-Compose](https://docs.docker.com/compose/install/)
* make

### Local .env file preparation
To properly build and start the containers required for local operation of the 3tier application, one needs to create a .env file in the root directory of the cloned repository with the following content (*the variables should be set according to ones' environment*):

```
CI_REGISTRY=mgstoptal
COMPOSE_PROJECT_NAME=toptal3tier
TAG=1.0
POSTGRES_USER=root
POSTGRES_PASSWORD=pwd0123456789
POSTGRES_DB=mydb
NODE_ENV=production
WEB_PORT=3000
API_PORT=3000
DOCKER_USERNAME=<DOCKER HUB USERNAME>
DOCKER_PASS=<DOCKER HUB PASSWORD>
```

### Local container management
After preparing the environment file, the containers can be built with:

```
make local-build
```

When this succeeds, the containers can be started with:

```
make local-run
```

The containers should be accessible (with the default configuration) at:

```
http://${DOCKER_HOST}:3000/ for the WEB container
http://${DOCKER_HOST}:3001/ for the API container
```

or stopped wtih:

```
make local-stop
```

### Local containers pushing to registry
When one is satisfied with their changes they can be pushed to the container registry with

```
make local-push
```

## Remote deployment
### Prerequisites

Once the containers are pushed to the remote container registry, the application can be deployed to AWS. In order for that to happen successfully, the following software should be installed and configured:

* [Terraform 12+](https://www.terraform.io/downloads.html)
* [AWS Cli](https://aws.amazon.com/cli/)
* make

This step requires creation of a AWS user with the following autorizations:

*  AmazonRDSFullAccess
*  IAMFullAccess
*  ElasticLoadBalancingFullAccess
*  AmazonS3FullAccess
*  CloudWatchFullAccess
*  AmazonDynamoDBFullAccess
*  CloudFrontFullAccess
*  AmazonECS_FullAccess
*  AmazonVPCFullAccess

This user doesn't require AWS console access, however it needs to make REST or HTTP Query protocol requests to AWS service APIs. 
### Infrastructure deployment
Once the account is created, the **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** need to be made available to terraform:

```
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
```

Then from the same shell, first create terraform remote state/lock database:

```
make bootstrap-plan
make bootstrap-apply
```

And once successful, the environment can be deployed:

```
make toptal3tier-plan
make toptal3tier-apply
```

### Application management
If a deploy of a new (or previous) version of the application is necessary, that can be achieved by running:

```
make toptal3tier-deploy container_tag=<The tag of the containers>
```

### Infrastructure teardown
Don't forget to destroy the AWS environment when not needed, since it **will** incur costs.

```
make toptal3tier-destroy
```

Answer yes when prompted! Although not strictly necessary, the remote terraform state and lock database can be removed with:

```
make bootstrap-destroy
```