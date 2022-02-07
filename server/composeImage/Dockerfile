#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



FROM docker:20.10

WORKDIR /usr/local/lib/docker/cli-plugins

ADD https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 docker-compose
RUN chmod +x docker-compose

ADD https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-amd64 docker-buildx
RUN chmod +x docker-buildx

RUN docker buildx install