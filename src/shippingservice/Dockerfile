FROM golang:1.21-alpine as build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o ./service .

FROM alpine

ENV DISABLE_TRACING 1
ENV DISABLE_PROFILER 1
ENV DISABLE_STATS 1

EXPOSE 50051

WORKDIR /app

COPY --from=build /app/service ./service 

ENTRYPOINT ["/app/service"]