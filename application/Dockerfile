# syntax=docker/dockerfile:1.3
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Build wheels.
#-------------------------------------------------------------------------------
FROM python:3.10-alpine3.16 as wheelBuilder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache gcc musl-dev linux-headers zlib-dev postgresql-dev libmemcached-dev

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip wheel	\
	&& pip wheel --no-cache-dir --progress-bar off --wheel-dir wheels/ -r requirements.txt



# 
# Compile LESS.
#-------------------------------------------------------------------------------
FROM alpine:3.16 as lessBuilder

RUN apk add --no-cache bash npm findutils	\
	&& npm install --global less

RUN --mount=source=./,target=application/ application/scripts/less.sh



# 
# Image.
#-------------------------------------------------------------------------------
FROM python:3.10-alpine3.16

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache curl libpq libmemcached
RUN --mount=from=wheelBuilder,source=wheels/,target=wheels/		\
	pip install --no-cache-dir --upgrade pip					\
	&& pip install --no-cache-dir wheels/*

RUN addgroup -S django && adduser -Ss /sbin/nologin -G django django
USER django
WORKDIR /home/django

COPY --chown=django:django . .
COPY --chown=django:django --from=lessBuilder deployment/static/siteApp/css/siteApp.css deployment/static/siteApp/css/siteApp.css

ENV PATH="${PATH}:/home/django"
ENTRYPOINT [ "/bin/sh", "-c" ]
EXPOSE 3031