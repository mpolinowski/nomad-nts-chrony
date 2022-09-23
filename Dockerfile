FROM alpine:latest

ARG BUILD_DATE

# first, a bit about this container
LABEL build_info="nomad/chrony-nts build-date:- ${BUILD_DATE}"
LABEL maintainer="Mike Polinowski <mpolinowski@gmail.com>"
LABEL documentation="https://github.com/mpolinowski/nomad-nts-chrony"

# install chrony
RUN apk add --no-cache chrony

# script to configure/startup chrony (ntp)
COPY assets/startup.sh /opt/startup.sh

# ntp and nts port
EXPOSE 123/udp 4460/tcp

# let docker know how to test container health
HEALTHCHECK CMD chronyc tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/sh", "/opt/startup.sh" ]
