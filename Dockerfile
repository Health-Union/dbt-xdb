FROM python:3.7

RUN apt-get update -y && \
apt-get install -y vim && \
pip3 install dbt 
mkdir /app 

COPY . /app
WORKDIR /app/test_xdb

RUN python3 scripts/test_setup.py
