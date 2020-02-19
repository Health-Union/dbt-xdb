FROM python:3.7

RUN mkdir /app
WORKDIR /app

RUN apt-get update -y && pip3 install dbt

