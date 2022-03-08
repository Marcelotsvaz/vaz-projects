# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



FROM docker:20.10

WORKDIR /usr/local/lib/docker/cli-plugins

RUN wget -q https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -O docker-compose	\
	&& chmod +x docker-compose

RUN wget -q https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-amd64 -O docker-buildx	\
	&& chmod +x docker-buildx

RUN docker buildx install