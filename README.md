# SelectQuote Rocket League
This repo contains two rocket league applications that connect clients to
a backend rocket league server instance.


## rl-web
Directory that contains the frontend web rocket league flask application.
The application listens for connecting clients then conencts them to our
rl-internal backend application running on EC2.



#### CI
There is a CI Github Actions Workflow [here](.github/workflows/rl-web-main.yml) that will run whenever a PR is
opened against `main`. The workflow will build the docker container as well as
run linting and formatting with `ruff`. These jobs will need to pass before PRs
are allowed to merge into `main`.


#### Deployments
The deployments for this ECS service are handled by a Github Action [here](.github/workflows/rl-web-deploy.yml)

- prod: semver tags created


## rl-internal
Directory that contains our backend rocket league server flask application.

*NOTE*: Only accessable by the rl-web ECS service.


#### CI
There is a CI Github Actions Workflow [here](.github/workflows/rl-internal-main.yml) that will run whenever a PR is
opened against `main`. The workflow will build the docker container as well as
run linting and formatting with `ruff`. These jobs will need to pass before PRs
are allowed to merge into `main`.


#### Deployments
The deployments for the EC2 instances are handled by a Github Action [here](.github/workflows/rl-internal-deploy.yml).

- prod: semver tags created


## terraform
Directory containing terraform for all infrastructure related to the Rocket
League Applications

There is a Github Actions Workflow [here](.github/workflows/terraform-plan.yml) that will run whenever a PR
is opened against `main`. This workflow will test formating, validation, and run
a plan and then return the output to a comment in the PR. These jobs will need to
pass before merges are allowed into `main`.


#### Deployments
Deployments are manged by a Github Actions Workflow [here](.github/workflows/terraform-apply.yml)

- prod: semver tags created
