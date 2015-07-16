require 'rubygems'
require 'evernote_oauth'

class EvernoteGistStore
  def initialize(folder, authToken, sandbox=false)
    @client = EvernoteOAuth::Client.new(token: authToken, sandbox: sandbox)
    @note_store =  @client.note_store
    notebookList = @note_store.listNotebooks()
    @notebooks = {}
    notebookList.each do |notebook|
      @notebook = notebook if notebook.name  == folder
      @notebooks[notebook.name] = notebook
    end
    unless @notebook
      raise "Can't find #{folder}"
    end
  end

  def tags(tagnames)
    @tags = @note_store.listTags().select do |tag|
      tagnames.include? tag.name
    end
  end

  def import(gist, guid = nil)
    note = Evernote::EDAM::Type::Note.new()
    note.title = gist.title
    note.notebookGuid = @notebook.guid
    note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
      '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>'+
      "<a href='#{gist.url}'>#{gist.url}</a><p>#{gist.content}</p></en-note>"
    if @tags
      note.tagGuids = @tags.map do |t| t.guid end
    end
    if guid
      p "Updating #{note.title}"
      note.guid = guid
      @note_store.updateNote(note)
    else
      p "Creating #{note.title} for #{gist.url}"
      @note_store.createNote(note)
    end
  end
end
