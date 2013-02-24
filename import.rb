require 'rubygems'
require 'evernote_oauth'
require './gist'
require './gists'
require 'yaml'

config = YAML.load_file(File.expand_path('../config.yml', __FILE__))


# Authenticate
authToken = config['Evernote'][:token]
client = EvernoteOAuth::Client.new(token: authToken, sandbox: false)
gists = Gists.new(config["Github"][:username], config["Github"][:password]).get.reverse
folder = config["Evernote"][:folder]

@note_store =  client.note_store
notebooks = @note_store.listNotebooks()

notebooks.each do |notebook|
  if notebook.name == folder
    puts "Found #{notebook.name}"
    @notebook = notebook
  end
end

def import(gist, guid = nil)
  note = Evernote::EDAM::Type::Note.new()
  note.title = gist.title
  note.notebookGuid = @notebook.guid
  note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
    '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>'+
    "<a href='#{gist.url}'>#{gist.url}</a><p>#{gist.content}</p></en-note>"
  if guid
    p "Updating #{note.title}"
    note.guid = guid
    @note_store.updateNote(note)
  else
    p "Creating #{note.title}"
    @note_store.createNote(note)
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

