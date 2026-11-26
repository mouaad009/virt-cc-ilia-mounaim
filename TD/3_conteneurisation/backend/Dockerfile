FROM debian:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash htop vim net-tools \
    && rm -rf /var/lib/apt/lists/*

ENV OWNER=Mouaad
CMD ["sleep", "3600"]
