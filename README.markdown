![Evernote and Gist](http://i.imgur.com/AF5OsTQ.png)
## Gist Evernote Importer

Relies of the Evernote gem, Typhoeus, and Datamapper to quickly import and
keep your gists up to date inside of Evernote.

### Why

I use evernote for saving things like receipts and business cards, and random
digital cruft I accumulate over the course of my day.

The only thing missing was my Github Gists. For that matter, Gists in general
are a great way to stash code snippets, but have no means of searching.

Evernote on the other hand has great search capabilities, but TERRIBLE support
for code snippets.

This project tries to rectify the situation.

### Dependencies

Installation requires the bundle gem, curl, git, ruby-dev, make, libsqlite3-dev and an editor such as vim e.g. (on Ubuntu 14.04):

    apt-get update
    apt-get install -y curl git ruby-dev make libsqlite3-dev vim
    gem install bundle --no-rdoc --no-ri

### Installation

First, get an API token from Evernote. This will let you access just your account.

[https://www.evernote.com/api/DeveloperToken.action](https://www.evernote.com/api/DeveloperToken.action)

    git clone https://github.com/mdp/GistEvernoteImport.git
    cd GistEvernoteImport
    mv config.yml.sample config.yml
    vim config.yml # Add your Evernote token and Github information here
    bundle install
    bundle exec ruby import.rb

If anything in your gists change, this will automatically update to appropriate
note in Evernote with the information on the next run.

### How

There's a sqlite database storing the Gist, the Evernote Guid, and the current
hash of all the files. Any changes to the gist makes the hash invalid, which
then updates the Evernote note with the matching Guid.
