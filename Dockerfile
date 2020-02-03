FROM openjdk:11-jdk-slim as builder
ENV APP_HOME=/app/example/
WORKDIR $APP_HOME

# copies gradle related files to build stage image
COPY build.gradle settings.gradle gradlew $APP_HOME
COPY gradle $APP_HOME/gradle

# downloads and caches dependencies in image layer
# so that they don't have to be re-downloaded each time
RUN ./gradlew build || return 0

# builds executable jar
COPY . .
RUN ./gradlew shadowJar

# uses minimal distroless container for runtime
# FROM gcr.io/distroless/java:11
FROM adoptopenjdk/openjdk11:x86_64-debianslim-jdk-11.0.6_10-slim
WORKDIR /app/example/

RUN DD_AGENT_MAJOR_VERSION=7 DD_SITE="datadoghq.eu" bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"

# takes executable jar from build stage
COPY --from=builder /app/example/build/libs/example-1.0.0-SNAPSHOT-fat.jar example.jar

# uses non-root user
USER nobody:nobody

# starts and exposes application
EXPOSE 8888
ENTRYPOINT ["java", "-jar", "example.jar"]
