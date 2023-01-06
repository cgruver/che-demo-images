FROM quay.io/centos/centos:stream9

ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"

ENV HOME=${USER_HOME_DIR}
ENV _BUILDAH_STARTED_IN_USERNS=""
ENV BUILDAH_ISOLATION=chroot

RUN dnf install -y openssl compat-openssl11 git tar which shadow-utils bash zsh wget jq podman buildah skopeo; \
    dnf update -y ; \
    dnf clean all ; \
    mkdir -p ${USER_HOME_DIR} ; \
    mkdir -p ${WORK_DIR} ; \
    chgrp -R 0 /home ; \
    #
    # Setup for root-less podman
    #
    setcap cap_setuid+ep /usr/bin/newuidmap ; \
    setcap cap_setgid+ep /usr/bin/newgidmap ; \
    touch /etc/subgid /etc/subuid ; \
    chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR} ; \
    echo user:10000:65536 > /etc/subuid  ; \
    echo user:10000:65536 > /etc/subgid

USER 10001
WORKDIR /projects