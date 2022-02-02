#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



FROM python:3.10.2-bullseye

WORKDIR /usr/src/app/

# ENV PYTHONDONTWRITEBYTECODE 1
# ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install --yes --no-install-recommends --quiet libmemcached-dev && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --upgrade pip wheel

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENTRYPOINT [ "./manage.py" ]

# user
# requirements
# tag
# compose build
# secrets
# expose





# FROM python:3.6-alpine as base                                                                                                
                                                                                                                              
# FROM base as builder                                                                                                          
                                                                                                                              
# RUN mkdir /install                                                                                                            
# RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev                                                             
# WORKDIR /install                                                                                                              
# COPY requirements.txt /requirements.txt                                                                                       
# RUN pip install --install-option="--prefix=/install" -r /requirements.txt                                                     
                                                                                                                              
# FROM base                                                                                                                     
                                                                                                                              
# COPY --from=builder /install /usr/local                                                                                       
# COPY src /app                                                                                                         
# RUN apk --no-cache add libpq                                                                                                  
# WORKDIR /app