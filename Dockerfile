FROM eclipse-temurin:21-jre

WORKDIR /data

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Download the Playit Agent
RUN --rm -it --net=host -e SECRET_KEY=7718d46a114ddac1ff2c517aa50348dbb485f0596850ff2f80aa9bfc19d46b42 ghcr.io/playit-cloud/playit-agent:0.17
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
