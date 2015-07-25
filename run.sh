#!/bin/bash

if [ ! -f ./data/config.yml ]; then
      echo "Config file not found, please run setup.rb"
fi
bundle exec ruby import.rb
