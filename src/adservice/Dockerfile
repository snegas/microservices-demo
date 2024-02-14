FROM --platform=linux/amd64 amazoncorretto:21 as build

WORKDIR /app

RUN yum -y update && yum -y install gzip tar wget && mkdir -p /opt/cprof && \
    wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent_alpine.tar.gz \
    | tar xzv -C /opt/cprof && \
    rm -rf profiler_java_agent.tar.gz

COPY gradle gradle
COPY gradlew* ./
RUN chmod +x ./gradlew && ./gradlew --help

COPY *.gradle ./

RUN ./gradlew downloadRepos --no-daemon

COPY . .

RUN chmod +x ./gradlew

RUN ./gradlew installDist --no-daemon --no-rebuild

FROM --platform=linux/amd64 amazoncorretto:21-alpine-jdk

COPY --from=build --chown=root:root /opt/cprof /opt/cprof

WORKDIR /app

COPY --from=build /app/build/install/hipstershop ./

ENV DISABLE_STATS=1
ENV DISABLE_TRACING=1

EXPOSE 9555

ENTRYPOINT [ "./bin/AdService" ]