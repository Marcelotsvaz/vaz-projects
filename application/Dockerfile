# syntax=docker/dockerfile:1.4
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

RUN apk add --no-cache git gcc musl-dev linux-headers zlib-dev postgresql-dev libmemcached-dev

COPY requirements.txt .
RUN <<EOF
	pip install --no-cache-dir --upgrade pip wheel
	pip wheel --no-cache-dir --progress-bar off --wheel-dir wheels/ -r requirements.txt
EOF



# 
# Compile LESS files.
#-------------------------------------------------------------------------------
FROM alpine:3.16 as lessBuilder

RUN <<EOF
	apk add --no-cache bash npm findutils
	npm install --global less
EOF

COPY scripts/less.sh application/scripts/
COPY *App/static/ application/allApp/static/
RUN application/scripts/less.sh



# 
# Build application image.
#-------------------------------------------------------------------------------
FROM python:3.10-alpine3.16

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache curl libpq libmemcached
RUN --mount=from=wheelBuilder,source=wheels/,target=wheels/ <<EOF
	pip install --no-cache-dir --upgrade pip
	pip install --no-cache-dir wheels/*
EOF

ARG dockerUser=django dockerUid=500
RUN <<EOF
	addgroup ${dockerUser} --system --gid ${dockerUid}
	adduser ${dockerUser} --system --uid ${dockerUid} --ingroup ${dockerUser}
EOF
USER ${dockerUser}
WORKDIR /home/${dockerUser}

COPY --link --chown=${dockerUid}:${dockerUid} . .
COPY --link --chown=${dockerUid}:${dockerUid} --from=lessBuilder deployment/static/siteApp/css/siteApp.css deployment/static/siteApp/css/

ENV PATH="${PATH}:/home/${dockerUser}"
ENTRYPOINT [ "/bin/sh", "-c" ]
EXPOSE 3031