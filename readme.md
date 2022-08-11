# VAZ Projects Website
This is the repository for [VAZ Projects](https://vazprojects.com).



## Running locally


### Install Docker Compose
```sh
# Install Docker, Buildx and Docker Compose.
pacman -Syu docker docker-compose	# On Arch Linux.
```

You might need to manually install Buildx and enable it by default with `docker buildx install`.


### Start Compose project
Make sure you have ports 80, 9000 and 9001 available.
```sh
# Clone the repository.
git clone https://gitlab.com/marcelotsvaz/vaz-projects.git
cd vaz-projects

# Build the application image and start all containers.
docker compose up --detach --build

# Create account for Django admin.
docker compose run --rm application './manage.py createsuperuser'
```

The following URLs will be available:
- Website: http://vaz-pc.lan
- Django admin: http://vaz-pc.lan/admin
- MinIO console: http://vaz-pc.lan:9001


### Running tests
```sh
# Run unit tests and generate coverage report.
docker compose run --rm application 'coverage run ./manage.py test && coverage report'
```


### Development
```sh
# Mount the application folder and the compiled LESS file to the container so you can make changes without rebuilding the image.
docker compose -f compose.yaml -f compose.development.yaml up --detach --build
```


### Cleanup
```sh
# Stop and remove all containers, data is preserved in named volumes.
docker compose down

# Also remove the volumes.
docker compose down --volumes
```