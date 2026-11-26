FROM debian:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash htop vim net-tools \
    && rm -rf /var/lib/apt/lists/*

ENV OWNER=Mouaad

RUN useradd nonroot
USER nonroot
CMD ["sleep", "3600"]
