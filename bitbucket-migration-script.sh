#!/bin/bash
# Author:RayNg@Vibrato

# Usage: ./bitbucket-migration-script.sh repos.txt
#
# repos.txt should have one repository per line.

echo "Reading $1"
readonly bsUser=$BITBUCKET_SERVER_USER
readonly bsServer=$BITBUCKET_SERVER_URL #ssh
readonly bsSSHPort=$BITBUCKET_SERVER_PORT #ssh
readonly bsProjectKey=$BITBUCKET_SERVER_PROJECT_KEY
readonly bcUser=$BITBUCKET_CLOUD_USER
readonly bcPass=$BITBUCKET_CLOUD_PASS
readonly bcProjectKey=$BITBUCKET_CLOUD_PROJECT_KEY
readonly owner=$BITBUCKET_CLOUD_OWNER

while read line
do
        repo=$line
        echo "###"
        echo "Processing ${rep}"
        git clone --bare ssh://${bsUser}@${bsServer}:${bsSSHPort}/${bsProjectKey}/${repo}.git ./${repo}
        cd $repo
        echo "Creating repo in Bitbucket"
        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}" \
                     -H "Content-Type: application/json" \
                     -d '{"has_wiki": true, "is_private": true, "project": {"key": '\"${bcProjectKey}\"'}}'
        echo "Pushing mirror to bitbucket"
        echo "git@bitbucket.org:${owner}/${repo}.git"
        git push --mirror git@bitbucket.org:${owner}/${repo}.git
        cd ..
        echo "Removing ${repo}.git"
        rm -rf "${repo}"
        echo "Waiting 5 seconds"
        echo "###"
        sleep 5;

done < $1

exit
