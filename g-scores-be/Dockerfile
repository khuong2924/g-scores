FROM ruby:3.2.2

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm

RUN gem install bundler:2.6.3

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Create log directory and set permissions
RUN mkdir -p log tmp/pids && \
    chmod -R 777 log tmp

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]