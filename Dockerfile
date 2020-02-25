FROM python:3.7

RUN apt-get update -y && \
apt-get install -y vim && \
pip3 install dbt && \ 
mkdir /app && \
mkdir /dbt-xdb 

COPY macros /dbt-xdb/macros
COPY dbt_project.yml README.md /dbt-xdb/
COPY test_xdb /app

WORKDIR /app
