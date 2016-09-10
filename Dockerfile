FROM alpine:latest
RUN apk update && apk add --no-cache ruby ruby-irb ruby-dev make gcc libc-dev git icu-dev zlib-dev g++ cmake && gem install --no-ri --no-rdoc quality io-console bigdecimal rake
VOLUME /usr/app
RUN mkdir /usr/quality
ADD sample-project/Rakefile /usr/quality
WORKDIR /usr/app
COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh
