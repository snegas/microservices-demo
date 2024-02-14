FROM golang:1.21-alpine as build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o ./service .

FROM alpine

EXPOSE 5050

ENV SHIPPING_SERVICE_ADDR=shippingservice
ENV PRODUCT_CATALOG_SERVICE_ADDR=productcatalogservice
ENV CART_SERVICE_ADDR=cartservice
ENV CURRENCY_SERVICE_ADDR=currencyservice
ENV EMAIL_SERVICE_ADDR=emailservice
ENV PAYMENT_SERVICE_ADDR=paymentservice

WORKDIR /app

COPY --from=build /app/service ./service 

ENTRYPOINT ["/app/service"]