require 'data_mapper'
require  'dm-migrations'
require 'digest/sha1'
require 'htmlentities'
require 'uri'
require 'pygments'


cwd = File.expand_path('..', __FILE__)
DataMapper.setup(:default, "sqlite://#{cwd}/db.sql")

class GistSync
  include DataMapper::Resource
  property :id,           Serial    # An auto-increment integer key
  property :guid,         String    # A varchar type string, for short strings
  property :gist_id,      String    # A varchar type string, for short strings
  property :file_hash,    Text
  property :created_at,   DateTime  # A DateTime, for any date you might like.
end

DataMapper.auto_upgrade!

class Gist
  def initialize(gist)
    @gist = gist
    @style = nil
  end

  attr_writer :style

  def id
    @gist["id"]
  end

  def url
    @gist["html_url"]
  end

  def files
    @gist["files"]
  end

  def title
    desc = @gist["description"]
    if desc && desc.length > 0
      desc[0,255]
    else
      self.files.keys.first
    end
  end
  alias_method :description, :title

  def file_hash
    f = self.files.map {|k,v| v["raw_url"]}
    f.sort!
    Digest::SHA1.hexdigest f.join('')
  end

  def content
    requests = []
    hydra = Typhoeus::Hydra.new
    req2lang = {};
    self.files.each do |k,v|
      r = Typhoeus::Request.new(URI.encode(v["raw_url"]), :followlocation => true)
      hydra.queue(r)
      requests << r
      req2lang[r] = v["language"].downcase if @style
    end
    hydra.run
    concat = ''
    requests.each do |req|
      if req.response.headers['Content-Type'].match(/^image/)
        next #Skip images for simplicity
      end
      body = req.response.body
      if @style
        body = Pygments.highlight(body, :lexer => req2lang[req], :options => {:noclasses => true, :cssclass=> "", :style=> @style})

      end
      file_name = URI.decode(req.url[/([^\/]+)$/,1])
      concat << "<h2>#{file_name}</h2><pre>#{body}</pre>"
    end
    concat
  end
end
