FROM python:3.12-slim as base

RUN apt-get update -y && apt-get install -y --no-install-recommends g++

COPY requirements.txt . 
RUN pip install -r requirements.txt

FROM python:3.12-slim

WORKDIR /app

COPY --from=base /usr/local/lib/python3.12/ /usr/local/lib/python3.12/

COPY . .

ENV DISABLE_PROFILER=1
ENV PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice

EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]
