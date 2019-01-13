FROM ruby:alpine
RUN apk add --update \
  build-base \
  mariadb-dev \
  postgresql-dev \
  nodejs \
  tzdata \
  && rm -rf /var/cache/apk*
RUN gem install nokogiri
RUN mkdir -p /opt/bank
WORKDIR /opt/bank
COPY Gemfile /opt/bank/Gemfile
COPY Gemfile.lock /opt/bank/Gemfile.lock
RUN bundle config build.nokogiri --use-system-libraries && bundle install
CMD /bin/sh -c "rm -f /myapp/tmp/pids/server.pid && ./bin/rails server"
