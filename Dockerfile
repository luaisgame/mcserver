FROM eclipse-temurin:21-jre

WORKDIR /data

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Download the Playit Agent
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.17.0/playit-linux-amd64 \
    -o /usr/local/bin/playit-agent && \
    chmod +x /usr/local/bin/playit-agent

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
