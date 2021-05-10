FROM ruby:3.0.0

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y nodejs yarn cron vim
ENV APP_ROOT app
RUN mkdir /${APP_ROOT}
WORKDIR /${APP_ROOT}
COPY Gemfile /${APP_ROOT}/Gemfile
COPY Gemfile.lock /${APP_ROOT}/Gemfile.lock
RUN bundle update && bundle install
COPY . /${APP_ROOT}
# RUN mv database.yml /${APP_ROOT}/config/ && mv puma.rb /${APP_ROOT}/config/
# RUN bundle exec rails webpacker:clobber && yarn --check-files && bundle exec rails webpacker:compile

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]