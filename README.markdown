## Gist Evernote Importer

Relies of the Evernote gem, Typhoeus, and Datamapper to quickly import and
keep your gists up to date inside of Evernote.

### The reason

I use evernote for saving things like receipts and business cards, and random
digital cruft I accumulate over the course of my day.

The only thing missing with having my Github Gists imported and be searchable.
For that matter, Gists in general are a great way to stash code snippets, but
have no means of searching.

Evernote on the other hand has great search capabilities, but TERRIBLE support
for code snippets.

This lets me sync my Gists with Evernote, thereby solving the searching problem,
but lets me keep using and editing them on Github.

### Installation

First, get an API token from Evernote. This will let you access just your account.

https://www.evernote.com/api/DeveloperToken.action

Clone the repo, move config.yml.sample to config.yml and update with your
own info(including an API key from Evernote). Then run the bundler installer

    bundle install

Now you can simply run one command to import all your Gists

    ruby import.rb

If anything in your gists change, this will automatically update to appropriate
note in Evernote with the information

### How

There's a sqlite database storing the Gist, the Evernote Guid, and the current
hash of all the files. Any changes to the gist makes the hash invalid, which
then updates the Evernote note with the matching Guid.
