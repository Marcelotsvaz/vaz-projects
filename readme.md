# VAZ Projects Website
This is the repository for [VAZ Projects](https://vazprojects.com).



## Running locally


### Install Docker Compose
```sh
# Install Docker, Buildx and Docker Compose.
pacman -S docker docker-buildx docker-compose	# On Arch Linux.
```

You might need to enable buildx by default with `docker buildx install`.


### Start Compose project
Make sure you have ports 80, 9000 and 9001 available.

```sh
# Clone the repository.
git clone https://gitlab.com/marcelotsvaz/vaz-projects.git
cd vaz-projects/

# Build the application image and start all containers.
docker compose up --detach --build

# Create account for Django admin.
docker compose run --rm application 'manage.py createsuperuser'
```

The following URLs will be available:
- Website: http://localhost
- Django admin: http://localhost/admin
- MinIO console: http://localhost:9001


### Running tests
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