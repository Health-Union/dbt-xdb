FROM python:3.10

RUN apt-get update -y && \
apt-get install -y vim && \
mkdir /app && \
mkdir /dbt-xdb 

COPY macros /dbt-xdb/macros
COPY dbt_project.yml README.md  requirements.txt  /dbt-xdb/
COPY test_xdb /app

RUN pip3 install -r /dbt-xdb/requirements.txt

WORKDIR /app
