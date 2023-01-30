FROM registry.access.redhat.com/ubi9/ubi-minimal

ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"
ARG MAVEN_VERSION=3.8.7
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG JAVA_PACKAGE=java-17-openjdk-devel
ARG MANDREL_VERSION=22.3.0.1-Final
ARG USER_HOME_DIR="/home/user"
ARG WORK_DIR="/projects"
ARG GRAALVM_DIR=/opt/mandral

ENV HOME=${USER_HOME_DIR}
ENV BUILDAH_ISOLATION=chroot
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV MAVEN_HOME=/usr/share/maven
ENV MAVEN_CONFIG="${HOME}/.m2"
ENV GRAALVM_HOME=${GRAALVM_DIR}
ENV JAVA_HOME=/etc/alternatives/jre_17_openjdk

# Note: compat-openssl11 & libbrotli are needed for che-code (Che build of VS Code)

RUN microdnf --disableplugin=subscription-manager install -y openssl compat-openssl11 libbrotli git tar which shadow-utils bash zsh wget jq podman buildah skopeo glibc-devel zlib-devel gcc libffi-devel libstdc++-devel gcc-c++ glibc-langpack-en ca-certificates ${JAVA_PACKAGE}; \
    microdnf update -y ; \
    microdnf clean all ; \
    mkdir -p ${USER_HOME_DIR} ; \
    mkdir -p ${WORK_DIR} ; \
    chgrp -R 0 /home ; \
    #
    # Setup for root-less podman
    #
    setcap cap_setuid+ep /usr/bin/newuidmap ; \
    setcap cap_setgid+ep /usr/bin/newgidmap ; \
    mkdir -p "${HOME}"/.config/containers ; \
    (echo '[storage]';echo 'driver = "vfs"') > "${HOME}"/.config/containers/storage.conf ; \
    touch /etc/subgid /etc/subuid ; \
    chmod -R g=u /etc/passwd /etc/group /etc/subuid /etc/subgid /home ${WORK_DIR} ; \
    echo user:20000:65536 > /etc/subuid  ; \
    echo user:20000:65536 > /etc/subgid ; \
    #
    # Install Maven
    #
    TEMP_DIR="$(mktemp -d)" ; \
    mkdir -p /usr/share/maven /usr/share/maven/ref ; \
    curl -fsSL -o ${TEMP_DIR}/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz ; \
    tar -xzf ${TEMP_DIR}/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 ; \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn ; \
    rm -rf "${TEMP_DIR}" ; \
    #
    # Install Mandrel
    #
    mkdir -p ${GRAALVM_DIR} ; \
    TEMP_DIR="$(mktemp -d)" ; \
    curl -fsSL -o ${TEMP_DIR}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}/mandrel-java17-linux-amd64-${MANDREL_VERSION}.tar.gz ; \
    tar xzf ${TEMP_DIR}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz -C ${GRAALVM_DIR} --strip-components=1 ; \
    rm -rf "${TEMP_DIR}" ; \
    #
    # Install Github CLI
    #
    TEMP_DIR="$(mktemp -d)" ; \
    cd "${TEMP_DIR}"; \
    GH_VERSION="2.0.0"; \
    GH_ARCH="linux_amd64"; \
    GH_TGZ="gh_${GH_VERSION}_${GH_ARCH}.tar.gz"; \
    GH_TGZ_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_TGZ}"; \
    GH_CHEKSUMS_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_checksums.txt"; \
    curl -sSLO "${GH_TGZ_URL}"; \
    curl -sSLO "${GH_CHEKSUMS_URL}"; \
    sha256sum --ignore-missing -c "gh_${GH_VERSION}_checksums.txt" 2>&1 | grep OK; \
    tar -zxvf "${GH_TGZ}"; \
    mv "gh_${GH_VERSION}_${GH_ARCH}"/bin/gh /usr/local/bin/; \
    cd -; \
    rm -rf "${TEMP_DIR}" ; \
    #
    # Install YQ
    #
    TEMP_DIR="$(mktemp -d)" ; \
    YQ_VER="$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/mikefarah/yq/releases/latest))" ; \
    curl -fsSL -o ${TEMP_DIR}/yq.tar.gz https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_amd64.tar.gz ; \
    tar -xzf ${TEMP_DIR}/yq.tar.gz -C ${TEMP_DIR} ; \
    cp ${TEMP_DIR}/yq_linux_amd64 /usr/local/bin/yq ; \
    chmod +x /usr/local/bin/yq ; \
    rm -rf "${TEMP_DIR}" ; \
    #
    # Install Quarkus CLI
    #
    curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/ ; \
    curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio ; \
    rm -rf /root/.jbang

USER 10001
WORKDIR ${WORK_DIR}