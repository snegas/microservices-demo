FROM mcr.microsoft.com/dotnet/sdk:8.0 as build

WORKDIR /app

COPY *.csproj ./

RUN dotnet restore -r linux-musl-x64

COPY . .

RUN dotnet publish --no-restore \
    --self-contained true \
    -r linux-musl-x64 \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=True \
    -p:TrimMode=Full

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine-amd64

EXPOSE 8080

WORKDIR /app

COPY --from=build /app/bin/Release/net8.0/linux-musl-x64/publish ./

ENTRYPOINT [ "./cartservice" ]