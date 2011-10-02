## Gist Evernote Importer

Relies of the Evernote gem, Typhoeus, and Datamapper to quickly import and
keep your gists up to date inside of Evernote. Also makes use of the excellent
[Everton](http://githup.com/rubiojr/everton) code I stole.

### The reason

I use evernote for saving things like receipts and business cards, and random
digital cruft I accumulate over the course of my day.

The only thing missing with having my Github Gists imported and be searchable.
For that matter, Gists in general are a great way to stash code snippets, but 
have no means of searching.

Evernote on the other hand has great search capabilities, but TERRIBLE support
for code snippets. In fact their editor is probably among the worst I've used.

This lets me sync my Gists with Evernote, thereby solving the searching problem,
but lets me keep using and editing them on Github.

### Usage

This isn't gem, just a simple ruby project.

Clone the repo, move config.yml.sample to config.yml and update with your
own info(including an API key from Evernote)

Then run ruby import.rb and watch the import process scroll by.

If anything in your gists change, this will automatically update to appropriate
note in Evernote with the information


### How

There's a sqlite database storing the Gist, the Evernote Guid, and the current
hash of all the files. Any changes to the gist makes the hash invalid, which
then updates the Evernote note with the matching Guid.
