FROM ruby:3.2-alpine

RUN apk add --no-cache build-base git

# install dependencies
WORKDIR /srv/jekyll
COPY Gemfile Gemfile.lock ./
RUN bundle install

# copy rest of the files
COPY . .

# generate tags and categories
RUN ruby bin/generate_tags.rb && ruby bin/generate_categories.rb

CMD ["bundle", "exec", "jekyll", "serve", "--livereload", "--force_polling"]
