#!/bin/bash

echo "Generating categories..."
ruby bin/generate_categories.rb

echo "Generating posts..."
ruby bin/generate_tags.rb

echo "Building site..."
JEKYLL_ENV=production bundle exec jekyll build

echo "Publishing..."
rsync --delete --progress --stats -ru _site/* -e "ssh -i ~/memoryleaks.pem" ec2-user@ec2-18-196-68-187.eu-central-1.compute.amazonaws.com:/usr/share/nginx/html
