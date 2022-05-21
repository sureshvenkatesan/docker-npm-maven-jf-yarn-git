# using latest  alpine image  used in 3.8.5-eclipse-temurin-11-alpine in https://hub.docker.com/_/maven
# Only other files you want are in https://github.com/carlossg/docker-maven/tree/925e49a1d0986070208e3c06a11c41f8f2cada82/eclipse-temurin-11-alpine

FROM eclipse-temurin:11-jdk-alpine

## BEGIN install docker from https://hub.docker.com/_/docker i.e 20.10.16-alpine3.15

RUN apk add --no-cache \
        ca-certificates \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
        libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
        openssh-client

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV DOCKER_VERSION 20.10.16
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN set -eux; \
    \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        'x86_64') \
            url='https://download.docker.com/linux/static/stable/x86_64/docker-20.10.16.tgz'; \
            ;; \
        'armhf') \
            url='https://download.docker.com/linux/static/stable/armel/docker-20.10.16.tgz'; \
            ;; \
        'armv7') \
            url='https://download.docker.com/linux/static/stable/armhf/docker-20.10.16.tgz'; \
            ;; \
        'aarch64') \
            url='https://download.docker.com/linux/static/stable/aarch64/docker-20.10.16.tgz'; \
            ;; \
        *) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;; \
    esac; \
    \
    wget -O docker.tgz "$url"; \
    \
    tar --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
    ; \
    rm docker.tgz; \
    \
    dockerd --version; \
    docker --version

ENV DOCKER_BUILDX_VERSION 0.8.2
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        'x86_64') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64'; \
            sha256='c64de4f3c30f7a73ff9db637660c7aa0f00234368105b0a09fa8e24eebe910c3'; \
            ;; \
        'armhf') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm-v6'; \
            sha256='d0e5d19cd67ea7a351e3bfe1de96f3d583a5b80f1bbadd61f7adcd61b147e5f5'; \
            ;; \
        'armv7') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm-v7'; \
            sha256='b5bb1e28e9413a75b2600955c486870aafd234f69953601eecc3664bd3af7463'; \
            ;; \
        'aarch64') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm64'; \
            sha256='304d3d9822c75f98ad9cf57f0c234bcf326bbb96d791d551728cadd72a7a377f'; \
            ;; \
        'ppc64le') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-ppc64le'; \
            sha256='32b317d86c700d920468f162f93ae2282777da556ee49b4329f6c72ee2b11b85'; \
            ;; \
        'riscv64') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-riscv64'; \
            sha256='76d5fcf92ffa31b3e470d8ec1ab11f7b6997729e5c94d543fec765ad79ad0630'; \
            ;; \
        's390x') \
            url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-s390x'; \
            sha256='ec4bb6f271f38dca5a377a70be24ee2108a85f6e6ba511ad3b805c4f1602a0d2'; \
            ;; \
        *) echo >&2 "warning: unsupported buildx architecture ($apkArch); skipping"; exit 0 ;; \
    esac; \
    plugin='/usr/libexec/docker/cli-plugins/docker-buildx'; \
    mkdir -p "$(dirname "$plugin")"; \
    wget -O "$plugin" "$url"; \
    echo "$sha256 *$plugin" | sha256sum -c -; \
    chmod +x "$plugin"; \
    docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.5.0
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        'x86_64') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64'; \
            sha256='6296d17268c77a7159f57f04ed26dd2989f909c58cca4d44d1865f28bd27dd67'; \
            ;; \
        'armhf') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-armv6'; \
            sha256='92b423e2c4d0ca0a979d7b6a4fb13707612f8fa19b900bc6cd1c2cf83f2780c5'; \
            ;; \
        'armv7') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-armv7'; \
            sha256='d728dcbe5e20103e9b025efdbb6bfbca9ea9866851e669f7775fe3ebb7ab945c'; \
            ;; \
        'aarch64') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-aarch64'; \
            sha256='7efc61cc85fe712f14f04a6886d1481c96fe958be265f67482583b4b713b6a22'; \
            ;; \
        'ppc64le') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-ppc64le'; \
            sha256='e40af00a5f3ef87d31372f949134411b574042b8c055b2e5da12b92192405cb6'; \
            ;; \
        's390x') \
            url='https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-s390x'; \
            sha256='c36e48910f095d07d582b69363fb3f902bb6fab9e2bd3d5ed82a67d1b2279a39'; \
            ;; \
        *) echo >&2 "warning: unsupported compose architecture ($apkArch); skipping"; exit 0 ;; \
    esac; \
    plugin='/usr/libexec/docker/cli-plugins/docker-compose'; \
    mkdir -p "$(dirname "$plugin")"; \
    wget -O "$plugin" "$url"; \
    echo "$sha256 *$plugin" | sha256sum -c -; \
    chmod +x "$plugin"; \
    ln -sv "$plugin" /usr/local/bin/; \
    docker-compose --version; \
    docker compose version

#COPY modprobe.sh /usr/local/bin/modprobe
#COPY docker-entrypoint.sh /usr/local/bin/

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

#ENTRYPOINT ["docker-entrypoint.sh"]
#CMD ["sh"]
## END install docker

## BEGIN install git
# jq is needed in https://github.com/MaharshiPatel/SwampUp2022/blob/main/SUP016-Automate_everything_with_the_JFrog_CLI/lab-1/create_local_repos.sh
# coreutils is needed for base64 --decode
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh jq coreutils

## END install git

## BEGIN locale customization
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
RUN apk add --update --no-cache socat curl tzdata findutils

#https://stackoverflow.com/questions/63142193/how-do-i-set-timezone-for-my-docker-container
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## END locale customization

# BEGIN install jfrog CLI
RUN curl -fL https://install-cli.jfrog.io | sh
# END install jfrog CLI

## BEGIN of node from alpine (https://hub.docker.com/_/node -> 18-alpine3.14 i.e https://github.com/nodejs/docker-node/blob/38ae136a31e276da1dc6ff6a129a4e429304582d/18/alpine3.14/Dockerfile)
#FROM alpine:3.14

ENV NODE_VERSION 18.1.0

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
    && ARCH= && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        x86_64) \
          ARCH='x64' \
          CHECKSUM="db44a0003c61313ba466a486508353d013bc651973581acd9b9f4c71024cc7df" \
          ;; \
        *) ;; \
      esac \
  && if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
      && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  else \
    echo "Building from source" \
    # backup build
    && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      141F07595B7B3FFE74309A937405533BE57C7D57 \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && apk del .build-deps-full \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
  && apk del .build-deps \
  # smoke tests
  && node --version \
  && npm --version

ENV YARN_VERSION 1.22.18

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && apk del .build-deps-yarn \
  # smoke test
  && yarn --version

#COPY docker-entrypoint.sh /usr/local/bin/
#ENTRYPOINT ["docker-entrypoint.sh"]

#CMD [ "node" ]

## END of node 

## BEGIN of maven from alpine (https://github.com/carlossg/docker-maven/blob/master/jdk-8-alpine/Dockerfile)

#FROM eclipse-temurin:11-jdk-alpine

RUN apk add --no-cache curl tar bash procps

ARG MAVEN_VERSION=3.8.5
ARG USER_HOME_DIR="/root"
ARG SHA=89ab8ece99292476447ef6a6800d9842bbb60787b9b8a45c103aa61d2f205a971d8c3ddfb8b03e514455b4173602bd015e82958c0b3ddc1728a57126f773c743
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

RUN chmod  755 /usr/local/bin/mvn-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
