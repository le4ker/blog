#!/bin/bash

eval "$(rbenv init - zsh)"
JEKYLL_ENV=production jekyll serve --host "127.0.0.1" --baseurl ""
