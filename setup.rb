require 'highline/import'
require 'yaml'

puts "Setting up Github"
puts "You'll need your Github password or personal token for this step"
puts "You can get your personal token from https://github.com/settings/applications"

github_user = ask("Github Username: ")
github_pass = ask("Github password/personal token:  ") { |q| q.echo = false }

puts "Setting up evernote"
puts "You can get your development token from https://www.evernote.com/api/DeveloperToken.action"

evernote_token = ask("Evernote developer token: ") { |q| q.echo = false }
evernote_folder = ask("Evernote folder to sync gists to: ")

config = {
  "Evernote" => {
    :token => evernote_token,
    :folder => evernote_folder
  },
  "Github" => {
    :username => github_user,
    :password => github_pass
  }
}

filepath = ARGV[0] || "./data/config.yml"
puts "Saving credentials to #{filepath}"
File.open(filepath, 'w') { |file| file.write(config.to_yaml) }
puts "Done!"

#Evernote:
  ## Get your token at https://www.evernote.com/api/DeveloperToken.action
  #:token: "S=s2:U=9999:E=155331215e6c:C=13cbdbbd92d:P=9de:A=en-devtoken:H=aldskfjasdlfkjasdlfkj"
  #:folder: 'Gists'

#Github:
  #:username: 'username'
  #:password: 'password or personal token' #See: https://github.com/settings/applications
