FROM alpine:latest
RUN apk add --no-cache ruby ruby-irb ruby-dev make gcc libc-dev && gem install --no-ri --no-rdoc quality rake
VOLUME /usr/app
RUN mkdir /usr/quality
ADD sample-project/Rakefile /usr/quality
WORKDIR /usr/app
COPY entrypoint.sh .
ENTRYPOINT entrypoint.sh
