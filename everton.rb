require 'rubygems'
require 'evernote'
require 'yaml'
require 'uri'

#
# Great example fetched Evernote Forum at:
# http://forum.evernote.com/phpbb/viewtopic.php?f=43&t=27547
#

module Evernote
  class UserStore
    def validate_version
    end
  end
end

module Everton

  VERSION = '0.1.3'

  class Remote

    class << self
      attr_reader :user_store, :note_store, :shard_id
      attr_accessor :access_token
    end

    # @config parameter format
    #
    # :username
    # :password
    # :access_token
    # :user_store_url
    #
    # if @force is true, authenticate even if access_token found
    #
    def self.authenticate config, force=false
      if config.is_a? Hash
        cfg = config
      else
        cfg = YAML.load_file config
      end
      @user_store = Evernote::UserStore.new(cfg[:user_store_url], cfg)
      # We have a token, assume it's valid
      if not force and not config[:access_token].nil? and not config[:username].nil?
        @user = config[:username]
        @access_token = config[:access_token]
        @shard_id = @access_token.split(':').first.split('=').last
      else
        auth_result = user_store.authenticate
        @user = auth_result.user
        @access_token = auth_result.authenticationToken
        @shard_id = @user.shardId
      end
      uri = ::URI.parse cfg[:user_store_url]
      host = uri.host
      scheme = uri.scheme
      @note_store_url = "#{scheme}://#{host}/edam/note/#{@shard_id}"
      @note_store = Evernote::NoteStore.new(@note_store_url)
    end

  end

  class ::Evernote::EDAM::Type::Note
    def update
      Everton::Remote.note_store.updateNote(Everton::Remote.access_token, self)
    end
  end

  class ::Evernote::EDAM::Type::Notebook

    #
    # Add a text note and return it
    #
    def add_note(title, text)
      note = Evernote::EDAM::Type::Note.new()
      note.title = title
      note.notebookGuid = self.guid
      note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
                     '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>' +
                     text +
                     '</en-note>'
      Everton::Remote.note_store.createNote(Everton::Remote.access_token, note)
    end

    #
    # Add an image note and return it
    #
    def add_image(title, text, filename)
      image = File.open(filename, "rb") { |io| io.read }
      hashFunc = Digest::MD5.new
      hashHex = hashFunc.hexdigest(image)

      data = Evernote::EDAM::Type::Data.new()
      data.size = image.size
      data.bodyHash = hashHex
      data.body = image

      resource = Evernote::EDAM::Type::Resource.new()
      resource.mime = "image/png"
      resource.data = data;
      resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new()
      resource.attributes.fileName = filename

      note = Evernote::EDAM::Type::Note.new()
      note.title = title
      note.notebookGuid = self.guid
      note.content = '<?xml version="1.0" encoding="UTF-8"?>' +
          '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">' +
            '<en-note>' + text +
              '<en-media type="image/png" hash="' + hashHex + '"/>' +
                '</en-note>'
      note.resources = [ resource ]

      Everton::Remote.note_store.createNote(Everton::Remote.access_token, note)
    end

    # See advanced search
    # http://www.evernote.com/about/kb/article/advanced-search?lang=en
    #
    # http://www.evernote.com/about/developer/api/ref/NoteStore.html#Struct_NoteFilter
    #
    # http://www.evernote.com/about/developer/api/ref/NoteStore.html#Fn_NoteStore_findNotes
    def find_notes(filter=nil, params = {})
      f = Evernote::EDAM::NoteStore::NoteFilter.new()
      f.notebookGuid = self.guid
      f.words = filter if filter
      offset = params[:offset] || 0
      max_notes = params[:max_notes] || 20
      Everton::Remote.note_store.findNotes(Remote.access_token,f,offset,max_notes).notes
    end

  end

  class Notebook
    def self.all
      Remote.note_store.listNotebooks(Remote.access_token)
    end

    def self.create(name, params = {})
      n = Evernote::EDAM::Type::Notebook.new()
      n.name = name
      Remote.note_store.createNotebook(Remote.access_token, n)
    end

    def self.find(name)
      all.each do |n|
        return n if n.name == name
      end
      nil
    end

  end

end
