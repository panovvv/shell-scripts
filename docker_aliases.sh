#!/bin/bash

#
# Aliases
# (sorted alphabetically)
#

alias dps='docker ps'
alias dcps='docker-compose ps'

alias dex='docker exec -it'
alias dcex='docker-compose exec'

alias dlg='docker logs -f'
alias dclg='docker-compose logs -f'

alias dst='docker stop'
alias drm='docker rm'

alias dcup='docker-compose up -d'
alias dcdw='docker-compose down'

alias dkill='docker container stop $(docker container ls -aq) && docker container rm $(docker container ls -aq)'
