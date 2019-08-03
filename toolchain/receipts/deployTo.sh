#!/bin/bash

DMGFILES=( *.dmg )

# Deploy to bitrise
mkdir deploy
ls -la
mv ${$DMGFILES}.dmg deploy/

# Deploy to bitbucket
curl -X POST --user "${BB_AUTH_STRING}" "https://api.bitbucket.org/2.0/repositories/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/downloads" --form files=@"deploy/${DMGFILES}.dmg"

