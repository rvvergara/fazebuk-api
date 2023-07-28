FROM ruby:2.6.3

RUN apt-get update -qq \
    && apt-get install -y postgresql-client

WORKDIR /usr/src/app

RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY entrypoint.sh /usr/src/app/

EXPOSE 3000

COPY . .

CMD ["bash"]