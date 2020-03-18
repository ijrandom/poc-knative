# Use the official maven/Java 8 image to create a build artifact.
# https://hub.docker.com/_/maven
FROM gradle:6.2.2-jdk8 as builder

# Copy local code to the container image.
WORKDIR /app
COPY build.gradle .
COPY gradle ./gradle
COPY gradlew .
COPY settings.gradle .
COPY src ./src

# Build a release artifact.
RUN ./gradlew build -x test

# Use AdoptOpenJDK for base image.
# It's important to use OpenJDK 8u191 or above that has container support enabled.
# https://hub.docker.com/r/adoptopenjdk/openjdk8
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:8

# Copy the jar to the production image from the builder stage.
COPY --from=builder /app/build/libs/poc-knative-*.jar /poc-knative.jar

# Run the web service on container startup.
CMD ["java", "-jar", "/poc-knative.jar"]