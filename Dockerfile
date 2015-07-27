FROM ubuntu:14.04
MAINTAINER Mark Percival <m@mdp.im>

RUN apt-get update && \
    apt-get install -y curl ruby-dev make libsqlite3-dev zip && \
    gem install bundle --no-rdoc --no-ri && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    useradd -m evergist && \
    mkdir /app && \
    chown evergist /app

USER evergist

WORKDIR "/app"

RUN curl -L -O https://github.com/mdp/GistEvernoteImport/archive/master.zip && \
    unzip -j master.zip && \
    bundle install --path /app/.gem

VOLUME ["/app/data"]

CMD ["./run.sh"]

# Setup your credentials - will be written to /app/data/config.yml
#   docker run --rm -it -v $HOME/.gistevernote:/app/data mpercival/gistevernote bundle exec setup.rb
# Run it
#   docker run --rm -v $HOME/.gistevernote:/app/data mpercival/gistevernote
