#!/bin/bash

if [ ! -f ./data/config.yml ]; then
      echo "Config file not found"
      echo "Remember to create your config.yml file and place it in ./data"
      exit 1
fi
bundle exec ruby import.rb
