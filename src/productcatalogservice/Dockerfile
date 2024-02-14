FROM golang:1.21-alpine as build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o ./service .

FROM alpine

ENV DISABLE_PROFILER 1
ENV DISABLE_STATS 1

EXPOSE 3550

WORKDIR /app

COPY products.json ./
COPY --from=build /app/service ./service 

ENTRYPOINT ["/app/service"]