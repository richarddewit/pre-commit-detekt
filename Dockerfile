ARG DETEKT_VERSION=1.22.0
ARG ECLIPSE_TEMURIN_VERSION=19

FROM eclipse-temurin:$ECLIPSE_TEMURIN_VERSION as build-env
ARG DETEKT_VERSION

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip

# Create a custom Java runtime
RUN "$JAVA_HOME/bin/jlink" \
    --add-modules java.base \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

# hadolint ignore=DL3059
RUN mkdir /opt/detekt
WORKDIR /opt/detekt

# Download detekt
RUN curl -sSLO "https://github.com/detekt/detekt/releases/download/v$DETEKT_VERSION/detekt-cli-$DETEKT_VERSION-all.jar" && \
    mv "detekt-cli-$DETEKT_VERSION-all.jar" detekt-cli-all.jar

# Define the base image
FROM debian:buster-slim
ARG DETEKT_VERSION

# Install the custom Java runtime
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# for ktlint
ENV DEFAULT_JVM_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"
COPY --from=build-env /javaruntime $JAVA_HOME
COPY --from=build-env /opt/detekt /opt/detekt
WORKDIR /opt/detekt
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/opt/detekt/entrypoint.sh"]
