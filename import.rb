require 'rubygems'
require 'everton'
require 'gist'
require 'gists'
require 'yaml'

config = YAML.load_file(File.expand_path('../config.yml', __FILE__))

# Authenticate
Everton::Remote.authenticate config["Evernote"]
gists = Gists.new(config["Github"][:username], config["Github"][:password]).get.reverse
folder = config["Evernote"][:folder]

raise "#{folder} folder not found" unless @notebook = Everton::Notebook.find(folder)

def import(gist, guid = nil)
  note = Evernote::EDAM::Type::Note.new()
  note.title = gist.title
  note.notebookGuid = @notebook.guid
  note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>'+
    "<a href='#{gist.url}'>#{gist.url}</a><p>#{gist.content}</p></en-note>"
  p "Creating #{note.title}"
  if guid
    note.guid = guid
    Everton::Remote.note_store.updateNote(Everton::Remote.access_token, note)
  else
    Everton::Remote.note_store.createNote(Everton::Remote.access_token, note)
  end
end


gists.each do |gist|
  if record = GistSync.first(:gist_id => gist.id, :file_hash => gist.file_hash)
    p "Already saved #{gist.url}"
    # Do nothing
  else
    if record = GistSync.first(:gist_id => gist.id)
      p "Updating #{gist.url}"
      import(gist, record.guid)
      record.file_hash = gist.file_hash
      record.save
    else
      p "Creating #{gist.url}"
      note = import(gist)
      GistSync.create(:guid => note.guid, :file_hash => gist.file_hash, :gist_id => gist.id)
    end
  end
end

