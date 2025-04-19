FROM openjdk:25-jdk-slim-bookworm

LABEL org.opencontainers.image.name="photon-geocoder"
LABEL org.opencontainers.image.version="0.6.2"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        pbzip2 \
        wget \
        apt-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /photon

RUN wget -q https://github.com/komoot/photon/releases/download/0.6.2/photon-0.6.2.jar -O photon.jar

COPY entrypoint.sh ./entrypoint.sh
COPY download.sh ./download.sh
COPY country_codes.txt ./country_codes.txt

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./download.sh

EXPOSE 2322

ENTRYPOINT ["./entrypoint.sh"]