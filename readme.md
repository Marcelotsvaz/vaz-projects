[![Gitlab pipeline status](https://img.shields.io/gitlab/pipeline-status/marcelotsvaz%2Fvaz-projects?branch=production&logo=gitlab&label=Build)](https://gitlab.com/marcelotsvaz/vaz-projects/-/pipelines/latest)
[![Code coverage](https://img.shields.io/gitlab/pipeline-coverage/marcelotsvaz%2Fvaz-projects?branch=production&label=Coverage)](https://gitlab.com/marcelotsvaz/vaz-projects/-/pipelines/latest)
[![Renovate](https://img.shields.io/badge/Renovate-enabled-green?logo=renovatebot&logoColor=%23007fa0)](https://gitlab.com/marcelotsvaz/vaz-projects/-/issues/1)



# VAZ Projects Website
This is the repository for [VAZ Projects](https://vazprojects.com), my personal blog and project log. Its main purpose is to serve as a sandbox for my DevOps learning journey.



## Architecture Overview
The project consists of a Django application running on multiple EC2 instances within an Auto Scaling group. Traffic is routed to these instances using Traefik as the load balancer. A self-managed PostgreSQL instance is used as the database. Static and user-uploaded files are served through CloudFront.
![Architecture Overview Diagram](doc/architectureOverview.drawio.svg)

GitLab is used for continuous integration and continuous delivery. Each new commit triggers a pipeline that builds container images, runs tests, and deploys the new version to a staging environment. Deployment to production can be started with manual approval.

A Grafana/Prometheus/Loki stack is used to monitor user activity, application performance and instance resource utilization, as well as ingesting logs for different services.



## Running Locally


### Install Dependencies
```sh
# Install Docker, Buildx, Docker Compose and mkcert.
pacman -S docker docker-buildx docker-compose mkcert	# On Arch Linux.
```

You might need to enable buildx by default with `docker buildx install`.


### Project Setup

```sh
# Clone the repository.
git clone https://gitlab.com/marcelotsvaz/vaz-projects.git
cd vaz-projects/

# Create certificates with mkcert.
mkdir -p deployment/tls/

mkcert -ecdsa -install	# If not done yet.
mkcert -ecdsa -key-file deployment/tls/websiteKey.pem -cert-file deployment/tls/website.crt localhost minio
```


### Start Compose Project
Make sure you have ports 80, 443, 8080, 9000 and 9001 available.
```sh
# Build the application image and start all containers.
docker compose up --detach --build

# Create account for Django admin.
docker compose run --rm application 'manage.py createsuperuser'
```

The following URLs will be available:
- Application: https://localhost/
- Django admin: https://localhost/admin/
- Traefik dashboard: http://localhost:8080/dashboard/
- MinIO console: https://localhost:9001/


### Running Tests
```sh
# Run unit tests and generate coverage report.
docker compose run --rm --build application 'coverage run manage.py test && coverage report'
```


### Development
```sh
# Mount the application folder and the compiled LESS file into the container so you can test changes without rebuilding the image.
docker compose -f compose.yaml -f development.compose.yaml up --detach --build
```


### Cleanup
```sh
# Stop and remove all containers, data is preserved in named volumes.
docker compose down

# Stop and remove all containers, including volumes.
docker compose down --volumes
```