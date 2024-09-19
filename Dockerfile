FROM ruby:####
RUN apt-get update -qq && apt-get install -y nodejs npm
RUN npm install --global yarn
RUN yarn add jquery
RUN git clone https://github.com/loretoparisi/kakasi.git && cd kakasi && ./configure && make && make install
WORKDIR /gcv6
COPY Gemfile /gcv6/Gemfile
COPY Gemfile.lock /gcv6/Gemfile.lock
RUN bundle install
COPY . /gcv6


COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]
