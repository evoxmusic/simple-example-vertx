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
FROM gcr.io/distroless/java:11
WORKDIR /app/example/

# takes executable jar from build stage
COPY --from=builder /app/example/build/libs/example-1.0.0-SNAPSHOT-fat.jar example.jar

USER nobody:nobody

# starts and exposes application
EXPOSE 8888
ENTRYPOINT ["java", "-jar", "example.jar"]
