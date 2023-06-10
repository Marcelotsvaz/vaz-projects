# VAZ Projects Website
This is the repository for [VAZ Projects](https://vazprojects.com), my personal blog and project log. Its main purpose is to serve as a sandbox for my DevOps learning journey.



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
- Application: https://localhost
- Django admin: https://localhost/admin
- Traefik dashboard: https://localhost:8080
- MinIO console: https://localhost:9001


### Running Tests
```sh
# Run unit tests and generate coverage report.
docker compose run --rm --build application 'coverage run manage.py test && coverage report'
```


### Development
```sh
# Mount the application folder and the compiled LESS file to the container so you can make changes without rebuilding the image.
docker compose -f compose.yaml -f development.compose.yaml up --detach --build
```


### Cleanup
```sh
# Stop and remove all containers, data is preserved in named volumes.
docker compose down

# Also remove the volumes.
docker compose down --volumes
```