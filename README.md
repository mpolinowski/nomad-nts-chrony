# Chrony NTS with Hashicorp Nomad

Chrony Timeserver with NTS support.


> This repository is based on [docker-ntp](https://github.com/mpolinowski/docker-ntp) by [Chris Turra](https://github.com/cturra) but uses Hashicorp Nomad instead of Docker Compose to deploy the secure timeserver.


<!-- TOC -->

- [Chrony NTS with Hashicorp Nomad](#chrony-nts-with-hashicorp-nomad)
  - [Clone the Repository](#clone-the-repository)
  - [Build the Docker Image](#build-the-docker-image)
  - [Create Certificates](#create-certificates)
  - [Run the Container (Docker Compose)](#run-the-container-docker-compose)
    - [Running \& Testing](#running--testing)
    - [Container Logs](#container-logs)
      - [NTP Service](#ntp-service)
      - [NTS Service](#nts-service)
  - [Run the Container (Nomad)](#run-the-container-nomad)

<!-- /TOC -->


## Clone the Repository

```bash
git clone https://github.com/mpolinowski/nomad-nts-chrony
```

> __Note__: The `docker-compose` file expects the repository to be in `/opt/chrony-nts`.



## Build the Docker Image

Run the build script (you need to have docker installed):

```bash
./build.sh
```


## Create Certificates

Run `certbot` to create the TLS certificate for your domain:


```bash
apt install certbot python3-certbot-nginx
certbot certonly --standalone
```


## Run the Container (Docker Compose)

Use Docker Compose to run the container and mount/bind the TLS certificate:


```yml
version: '3.9'

services:
  chrony:
    build: .
    image: cturra/ntp:latest
    container_name: chrony
    restart: unless-stopped
    volumes:
      - type: bind
        source: /etc/letsencrypt/live/my.server.domain/fullchain.pem
        target: /opt/fullchain.pem
      - type: bind
        source: /etc/letsencrypt/live/my.server.domain/privkey.pem
        target: /opt/privkey.pem
    ports:
      - 123:123/udp
      - 4460:4460/tcp
    environment:
      - NTP_SERVERS=0.de.pool.ntp.org,time.cloudflare.com,time1.google.com
      - LOG_LEVEL=1
```


* __NTP_SERVERS__: Upstream NTP server to use.
* __LOG_LEVEL__: Levels can to specified: 0 (informational), 1 (warning), 2 (non-fatal error), and 3 (fatal error).



### Running & Testing

Test if the server is working:


### Container Logs

```bash
docker compose up -d chrony
docker compose logs chrony
```


#### NTP Service

```bash
apt install sntp
sntp time.instar.com
```

```bash
docker exec chrony chronyc tracking
docker exec chrony chronyc sources
docker exec chrony chronyc sourcestats
```


#### NTS Service

```bash
docker exec -ti chrony chronyd -Q -t 3 'server my.server.com iburst nts maxsamples 1'
docker exec -ti chrony chronyc serverstats
```

Check `NTS-KE connections accepted` and `Authenticated NTP packets`:


```bash
NTP packets received       : 3
NTP packets dropped        : 0
Command packets received   : 27
Command packets dropped    : 0
Client log records dropped : 0
NTS-KE connections accepted: 1
NTS-KE connections dropped : 0
Authenticated NTP packets  : 1
Interleaved NTP packets    : 0
NTP timestamps held        : 0
NTP timestamp span         : 0
```



## Run the Container (Nomad)

[./chrony_nts.nomad](https://mpolinowski.github.io/docs/DevOps/Hashicorp/2022-09-22--nomad-nts-timeserver/2022-09-22)