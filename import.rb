require "rubygems"
require "#{File.dirname(__FILE__)}/evernote_gist_store"
require "#{File.dirname(__FILE__)}/gist"
require "#{File.dirname(__FILE__)}/gists"
require "yaml"

config = YAML.load_file(File.expand_path('../data/config.yml', __FILE__))

# Authenticate
authToken = config['Evernote'][:token]
gists = Gists.new(config["Github"][:username], config["Github"][:password]).get.reverse
folder = config["Evernote"][:folder]

evernote_gist_store = EvernoteGistStore.new(folder, authToken)

gists.each do |gist|
  if record = GistSync.first(:gist_id => gist.id, :file_hash => gist.file_hash)
    p "Already saved #{gist.url}"
    # Do nothing
  else
    if record = GistSync.first(:gist_id => gist.id)
      evernote_gist_store.import(gist, record.guid)
      record.file_hash = gist.file_hash
      record.save
    else
      note = evernote_gist_store.import(gist)
      GistSync.create(:guid => note.guid, :file_hash => gist.file_hash, :gist_id => gist.id)
    end
  end
end

