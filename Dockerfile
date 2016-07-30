FROM alpine:latest
RUN apk add --no-cache ruby ruby-irb ruby-dev make gcc libc-dev && gem install --no-ri --no-rdoc quality
RUN gem install --no-ri --no-rdoc rake
VOLUME /usr/app
RUN mkdir /usr/quality
ADD sample-project/Rakefile /usr/quality
WORKDIR /usr/app
CMD rake -f /usr/quality/Rakefile quality
