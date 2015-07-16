require "rubygems"
require "#{File.dirname(__FILE__)}/evernote_gist_store"
require "#{File.dirname(__FILE__)}/gist"
require "#{File.dirname(__FILE__)}/gists"
require "yaml"

config = YAML.load_file(File.expand_path('../config.yml', __FILE__))

# Authenticate
authToken = config['Evernote'][:token]
gists = Gists.new(config["Github"][:username], config["Github"][:password]).get.reverse
folder = config["Evernote"][:folder]

evernote_gist_store = EvernoteGistStore.new(folder, authToken)
evernote_gist_store.tags(config["Evernote"][:tagnames])
gists.each do |gist|
  if !config['force_update'] and record = GistSync.first(:gist_id => gist.id, :file_hash => gist.file_hash)
    p "Already saved #{gist.url}"
    # Do nothing
  else
    gist.style = config['code_highlighting_style']
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

