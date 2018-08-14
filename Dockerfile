FROM alpine:latest AS build
RUN apk update && apk add --no-cache ruby ruby-irb ruby-dev make gcc libc-dev git icu-dev zlib-dev g++ cmake openssl-dev  && gem install --no-ri --no-rdoc io-console bigdecimal rake
ARG quality_gem_version
RUN gem install --no-ri --no-rdoc quality:${quality_gem_version}





FROM alpine:latest AS base
VOLUME /usr/app
RUN mkdir /usr/quality
ADD sample-project/Rakefile /usr/quality/Rakefile
WORKDIR /usr/app
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["quality"]





FROM base AS latest
COPY --from=0 /usr/lib/ruby/gems /usr/lib/ruby/gems





FROM base AS python-base
#
# Install flake8 and pycodestyle
#

# Note: flake8 actually uses pycodestyle internally, and requires the
# version installed be less than 2.4.0:
#
# https://gitlab.com/pycqa/flake8/issues/406
# https://gitlab.com/pycqa/flake8/blob/master/setup.py
#
RUN apk add --no-cache python3 py3-pip && \
    pip3 install flake8 'pycodestyle<2.4.0'




FROM build AS python-build
COPY --from=0 /usr/lib/ruby/gems /usr/lib/ruby/gems
RUN apk update && apk add --no-cache ruby ruby-dev # TODO: Do this as another build image
RUN gem install --no-ri --no-rdoc pronto pronto-reek pronto-rubocop pronto-flake8 pronto-flay





FROM python-base AS python
COPY --from=4 /usr/lib/ruby/gems /usr/lib/ruby/gems
VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["quality"]




FROM python-base AS shellcheck-builder

#
# Install shellcheck
#

# https://github.com/mitchty/alpine-ghc
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub

RUN echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/8.0" >> /etc/apk/repositories && \
    apk add --no-cache ghc cabal stack

# https://github.com/NLKNguyen/alpine-shellcheck/blob/master/builder/Dockerfile
RUN apk add --no-cache build-base git wget

RUN mkdir -p /usr/src/shellcheck
WORKDIR /usr/src/shellcheck

RUN git clone https://github.com/koalaman/shellcheck .
RUN cabal update && cabal install

ENV PATH="/root/.cabal/bin:$PATH"


FROM python-base AS shellcheck-base

COPY --from=6 /root/.cabal/bin /usr/local/bin




FROM shellcheck-base as shellcheck

COPY --from=0 /usr/lib/ruby/gems /usr/lib/ruby/gems
RUN apk update && apk add --no-cache ruby ruby-dev # TODO: Do this as another build image
RUN gem install --no-ri --no-rdoc pronto pronto-reek pronto-rubocop pronto-flake8 pronto-shellcheck pronto-flay
ARG quality_gem_version

VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["quality"]




FROM shellcheck-base AS jumbo

# https://github.com/sgerrand/alpine-pkg-glibc
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
    apk add glibc-2.28-r0.apk

ENV LANG=C.UTF-8

# https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/~/dockerfile/

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=181 \
    JAVA_BUILD=13 \
    JAVA_PATH=96a7b8442fe848ef90c96a2fad6ed6d1 \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip && \
    cd "/tmp" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PATH}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" "$JAVA_HOME" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    rm -rf "$JAVA_HOME/"*src.zip && \
    rm -rf "$JAVA_HOME/lib/missioncontrol" \
           "$JAVA_HOME/lib/visualvm" \
           "$JAVA_HOME/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/plugin.jar" \
           "$JAVA_HOME/jre/lib/ext/jfxrt.jar" \
           "$JAVA_HOME/jre/bin/javaws" \
           "$JAVA_HOME/jre/lib/javaws.jar" \
           "$JAVA_HOME/jre/lib/desktop" \
           "$JAVA_HOME/jre/plugin" \
           "$JAVA_HOME/jre/lib/"deploy* \
           "$JAVA_HOME/jre/lib/"*javafx* \
           "$JAVA_HOME/jre/lib/"*jfx* \
           "$JAVA_HOME/jre/lib/amd64/libdecora_sse.so" \
           "$JAVA_HOME/jre/lib/amd64/"libprism_*.so \
           "$JAVA_HOME/jre/lib/amd64/libfxplugins.so" \
           "$JAVA_HOME/jre/lib/amd64/libglass.so" \
           "$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so" \
           "$JAVA_HOME/jre/lib/amd64/"libjavafx*.so \
           "$JAVA_HOME/jre/lib/amd64/"libjfx*.so && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION}/jce_policy-${JAVA_VERSION}.zip" && \
    unzip -jo -d "${JAVA_HOME}/jre/lib/security" "jce_policy-${JAVA_VERSION}.zip" && \
    rm "${JAVA_HOME}/jre/lib/security/README.txt" && \
    apk del build-dependencies && \
    rm "/tmp/"*

# https://github.com/frol/docker-alpine-scala/blob/master/Dockerfile
ENV SCALA_VERSION=2.12.0-M5 \
    SCALA_HOME=/usr/share/scala

# NOTE: bash is used by scala/scalac scripts, and it cannot be easily replaced with ash.

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash && \
    cd "/tmp" && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del .build-dependencies && \
    rm -rf "/tmp/"*


#https://oss.sonatype.org/content/repositories/releases/org/scalastyle/scalastyle-batch_2.10/0.5.0/scalastyle_2.10-0.5.0.jar" && \

ENV SCALASTYLE_JAR=scalastyle_2.10-0.8.0-batch.jar

COPY etc/scalastyle_config.xml /usr/src/scalastyle_config.xml

RUN wget "https://oss.sonatype.org/content/repositories/releases/org/scalastyle/scalastyle_2.10/0.8.0/${SCALASTYLE_JAR}" && \
    echo '#!/bin/bash' > /bin/scalastyle && \
    echo "java -jar `pwd`/${SCALASTYLE_JAR}" --config "/usr/src/scalastyle_config.xml" '${@}' >> /bin/scalastyle && \
    chmod +x /bin/scalastyle




#
# Install flake8 and pycodestyle
#

# Note: flake8 actually uses pycodestyle internally, and requires the
# version installed be less than 2.4.0:
#
# https://gitlab.com/pycqa/flake8/issues/406
# https://gitlab.com/pycqa/flake8/blob/master/setup.py
#
RUN apk add --no-cache python3 py3-pip && \
    pip3 install flake8 'pycodestyle<2.4.0'


COPY --from=0 /usr/lib/ruby/gems /usr/lib/ruby/gems
RUN apk update && apk add --no-cache ruby ruby-dev # TODO: Do this as another build image
RUN gem install --no-ri --no-rdoc pronto pronto-reek pronto-rubocop pronto-flake8 pronto-shellcheck pronto-flay
ARG quality_gem_version


VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["quality"]
