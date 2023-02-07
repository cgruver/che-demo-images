FROM registry.access.redhat.com/ubi9/ubi-minimal
ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"
ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot
COPY --from=image-registry.openshift-image-registry.svc:5000/openshift/cli:latest /usr/bin/oc /usr/bin/oc
RUN microdnf --disableplugin=subscription-manager install -y openssl compat-openssl11 libbrotli git tar which shadow-utils bash zsh wget jq podman buildah skopeo; \
  microdnf update -y ; \
  microdnf clean all ; \
  mkdir -p ${USER_HOME_DIR} ; \
  mkdir -p ${WORK_DIR} ; \
  chgrp -R 0 /home ; \
  chgrp -R 0 ${WORK_DIR} ; \
  setcap cap_setuid+ep /usr/bin/newuidmap ; \
  setcap cap_setgid+ep /usr/bin/newgidmap ; \
  mkdir -p "${HOME}"/.config/containers ; \
  (echo '[storage]';echo 'driver = "vfs"') > "${HOME}"/.config/containers/storage.conf ; \
  touch /etc/subgid /etc/subuid ; \
  chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR} ; \
  echo user:20000:65536 > /etc/subuid  ; \
  echo user:20000:65536 > /etc/subgid
USER 10001
WORKDIR ${WORK_DIR}
