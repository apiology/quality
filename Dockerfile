FROM alpine:3.16 AS base

# We install and then uninstall quality to cache the dependencies
# while we still have the build tools installed but still be able to
# install the very latest quality gem later on without having the disk
# space impact of two versions.

RUN apk update && \
    apk add --no-cache ruby ruby-irb ruby-dev make gcc libc-dev git icu-dev zlib-dev g++ cmake openssl-dev coreutils && \
    gem update --system && \
    gem install --no-doc rdoc bigdecimal rake etc quality bundler io-console pronto pronto-reek pronto-rubocop pronto-flay pronto-punchlist pronto-bigfiles 'bundler:<2' && \
    gem uninstall quality && \
    strip /usr/lib/ruby/gems/*/extensions/x86_64-linux-musl/*/rugged-*/rugged/rugged.so && \
    apk del ruby-irb ruby-dev make gcc libc-dev icu-dev zlib-dev g++ cmake openssl-dev nghttp2 curl pax-utils && \
    apk add --no-cache libssl1.1 icu-libs && \
    rm -fr /usr/lib/ruby/gems/*/gems/rugged-*/vendor/libgit2/build/src \
           /usr/lib/ruby/gems/*/gems/rugged-*/vendor/libgit2/src \
           /usr/lib/ruby/gems/*/gems/rugged-*/ext/rugged \
           /usr/lib/ruby/gems/*/gems/rugged-*/vendor/libgit2/build/libgit2.a \
           /usr/lib/ruby/gems/*/gems/rugged-*/lib/rugged/rugged.so \
           /usr/lib/ruby/gems/*/gems/unf_ext-*/ext/unf_ext/unf \
           /usr/lib/ruby/gems/*/gems/kramdown-*/test \
           /usr/lib/ruby/gems/*/gems/ruby_parser-*/lib/*.y \
           /usr/lib/ruby/gems/*/gems/ruby_parser-*/lib/*.yy \
           /usr/lib/ruby/gems/*/gems/ruby_parser-*/lib/*.rex \
           /usr/lib/ruby/gems/*/cache \
           /usr/lib/ruby/gems/*/gems/erubis-*/doc-api \
           /usr/lib/ruby/gems/*/gems/reek-*/spec \
           /usr/lib/ruby/gems/*/gems/kwalify-*/doc-api \
      && \
      echo "Done"

RUN mkdir /usr/quality
ADD sample-project/.pronto.yml /usr/quality/.pronto.yml
ADD sample-project/Rakefile /usr/quality/Rakefile
COPY entrypoint.sh /


FROM base AS latest
VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
ARG quality_gem_version
RUN gem install --no-doc quality:${quality_gem_version}
CMD ["quality"]



FROM base AS python-base
#
# Install flake8 and pycodestyle
#

RUN apk add --no-cache python3 py3-pip && \
    pip3 install flake8 && \
    apk del py3-pip

# RUN gem install --no-doc pronto-flake8  # does not yet support pronto 0.11



FROM python-base AS python
VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
ARG quality_gem_version
RUN gem install --no-doc quality:${quality_gem_version}
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
RUN apk add --no-cache build-base git wget libffi-dev

RUN mkdir -p /usr/src/shellcheck
WORKDIR /usr/src/shellcheck

RUN git clone https://github.com/koalaman/shellcheck .
RUN cabal update && cabal install

ENV PATH="/root/.cabal/bin:$PATH"





FROM python-base as shellcheck-base

COPY --from=4 /root/.cabal/bin /usr/local/bin
RUN apk update && apk add --no-cache ruby ruby-dev # TODO: Do this as another build image
RUN gem install --no-doc pronto-shellcheck





FROM shellcheck-base as shellcheck
VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
ARG quality_gem_version
RUN gem install --no-doc quality:${quality_gem_version}
CMD ["quality"]





FROM shellcheck-base AS jumbo-base

# https://github.com/sgerrand/alpine-pkg-glibc
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
    apk add glibc-2.28-r0.apk

ENV LANG=C.UTF-8

# To upgrade:
# 1. Check https://jdk.java.net/19/ for latest build - see 'Alpine Linux/x64' link
# 2. See if there's an update here: https://github.com/docker-library/openjdk/blob/master/19/jdk/alpine3.16/Dockerfile

RUN apk add --no-cache java-cacerts

ENV JAVA_HOME /opt/openjdk-19
ENV PATH $JAVA_HOME/bin:$PATH

# https://jdk.java.net/
# >
# > Java Development Kit builds, from Oracle
# >
ENV JAVA_VERSION 19-ea+5
# "For Alpine Linux, builds are produced on a reduced schedule and may not be in sync with the other platforms."

RUN set -eux; \
	\
	arch="$(apk --print-arch)"; \
	case "$arch" in \
		'x86_64') \
			downloadUrl='https://download.java.net/java/early_access/alpine/5/binaries/openjdk-19-ea+5_linux-x64-musl_bin.tar.gz'; \
			downloadSha256='0ee67a41fe97341f131bd4f065ed6092d55c15de5f00f8ba1e57d21eefb2c787'; \
			;; \
		*) echo >&2 "error: unsupported architecture: '$arch'"; exit 1 ;; \
	esac; \
	\
	wget -O openjdk.tgz "$downloadUrl"; \
	echo "$downloadSha256 *openjdk.tgz" | sha256sum -c -; \
	\
	mkdir -p "$JAVA_HOME"; \
	tar --extract \
		--file openjdk.tgz \
		--directory "$JAVA_HOME" \
		--strip-components 1 \
		--no-same-owner \
	; \
	rm openjdk.tgz*; \
	\
	rm -rf "$JAVA_HOME/lib/security/cacerts"; \
# see "java-cacerts" package installed above (which maintains "/etc/ssl/certs/java/cacerts" for us)
	ln -sT /etc/ssl/certs/java/cacerts "$JAVA_HOME/lib/security/cacerts"; \
	\
# https://github.com/docker-library/openjdk/issues/212#issuecomment-420979840
# https://openjdk.java.net/jeps/341
	java -Xshare:dump; \
	\
# basic smoke test
	fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]; rm -rf ~/.java; \
	javac --version; \
	java --version

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

RUN cd /usr/lib && \
    wget "https://oss.sonatype.org/content/repositories/releases/org/scalastyle/scalastyle_2.10/0.8.0/${SCALASTYLE_JAR}" && \
    echo '#!/bin/bash' > /bin/scalastyle && \
    echo "java -jar `pwd`/${SCALASTYLE_JAR}" --config "/usr/src/scalastyle_config.xml" '${@}' >> /bin/scalastyle && \
    chmod +x /bin/scalastyle



FROM jumbo-base as jumbo
VOLUME /usr/app
WORKDIR /usr/app
ENTRYPOINT ["/entrypoint.sh"]
ARG quality_gem_version
RUN gem install --no-doc quality:${quality_gem_version}
CMD ["quality"]
