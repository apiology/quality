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
