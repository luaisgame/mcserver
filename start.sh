FROM eclipse-temurin:21-jre

WORKDIR /data

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor -o /usr/share/keyrings/playit.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit.list && \
    apt-get update && \
    apt-get install -y playit

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
