FROM ubuntu:14.04
MAINTAINER Mark Percival <m@mdp.im>

RUN apt-get update && apt-get install -y curl ruby-dev make libsqlite3-dev zip && gem install bundle --no-rdoc --no-ri
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m evergist
RUN mkdir /app && chown evergist /app
USER evergist

WORKDIR "/app"
RUN curl -L -O https://github.com/mdp/GistEvernoteImport/archive/master.zip && unzip -j master.zip
RUN bundle install --path /app/.gem

VOLUME ["/app/data"]

CMD ["./run.sh"]
