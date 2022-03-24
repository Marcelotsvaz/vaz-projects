# syntax=docker/dockerfile:1.3
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Build wheels.
#-------------------------------------------------------------------------------
FROM python:3.10-alpine3.15 as wheelBuilder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache gcc musl-dev linux-headers jpeg-dev zlib-dev postgresql-dev libmemcached-dev

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip wheel	\
	&& pip wheel --no-cache-dir --progress-bar off --wheel-dir wheels/ -r requirements.txt



# 
# Compile LESS.
#-------------------------------------------------------------------------------
FROM alpine:3.15 as lessBuilder

RUN apk add --no-cache npm findutils	\
	&& npm install --global less

RUN --mount=source=./,target=source/																	\
	lessc																								\
		--no-color																						\
		--source-map																					\
		--include-path="$(find source/*App/static/*App/css/src/ -prune -printf '%p:' | sed 's/:$//')"	\
		source/siteApp/static/siteApp/css/src/siteApp.less												\
		siteApp.css



# 
# Image.
#-------------------------------------------------------------------------------
FROM python:3.10-alpine3.15

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache curl libjpeg libpq libmemcached
RUN --mount=from=wheelBuilder,source=wheels/,target=wheels/		\
	pip install --no-cache-dir --upgrade pip					\
	&& pip install --no-cache-dir wheels/*

RUN addgroup -S django && adduser -Ss /sbin/nologin -G django django
USER django
WORKDIR /home/django

COPY --chown=django:django . .
COPY --chown=django:django --from=lessBuilder siteApp.css deployment/static/siteApp/css/siteApp.css

EXPOSE 3031