#!/bin/sh

# Deploy to bitrise
mkdir deploy
ls -la
mv *.dmg deploy/

# Deploy to bitbucket
DMGFILES=( deploy/*.dmg )
echo $DMGFILES
curl -X POST --user "${BB_AUTH_STRING}" "https://api.bitbucket.org/2.0/repositories/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/downloads" --form files=@"${DMGFILES}"
