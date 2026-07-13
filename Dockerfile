FROM eclipse-temurin:21-jre-jammy

RUN apt-get update \
    && apt-get install -y curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install the official Playit agent binary
RUN curl -L \
    https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
    -o /usr/local/bin/playit \
    && chmod +x /usr/local/bin/playit

WORKDIR /data

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
