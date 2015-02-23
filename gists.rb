require 'rubygems'
require 'typhoeus'
require 'json'
require "#{File.dirname(__FILE__)}/gist"


class Gists

  def initialize(username, password)
    @username, @password = username, password
  end

  def get
    next_page = 1
    gists = []
    while next_page do
      response = Typhoeus.get("https://api.github.com/gists?page=#{next_page}&per_page=100", :userpwd => "#{@username}:#{@password}")
      p "Querying Gist API for page ##{next_page}"
      next_page = response.headers_hash["Link"][/page=([0-9]+).+next/,1]
      JSON.parse(response.body).each do |gist|
        gists << Gist.new(gist)
      end
    end
    gists
  end

end
