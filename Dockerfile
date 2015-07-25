FROM ubuntu:14.04
MAINTAINER Mark Percival <m@mdp.im>

RUN apt-get update && apt-get install -y curl git ruby-dev make libsqlite3-dev && gem install bundle --no-rdoc --no-ri
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd / && git clone https://github.com/mdp/GistEvernoteImport.git app && \
    cd app && \
    git checkout dockerize
    bundle install

VOLUME ["/app/data"]

WORKDIR "/app"

CMD ["./run.sh"]
