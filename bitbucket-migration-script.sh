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
        ## create repository
        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}" \
                     -H "Content-Type: application/json" \
                     -d '{"has_wiki": true, "is_private": true, "project": {"key": '\"${bcProjectKey}\"'}}'
        ## Setup branch permission
        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}/branch-restrictions" \
             -H "Content-Type: application/json" \
             -d ' {
                     "pattern": "master",
                     "kind": "require_approvals_to_merge",
                     "value" : 1
                  }
                '

        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}/branch-restrictions" \
                     -H "Content-Type: application/json" \
                     -d ' {
                             "pattern": "master",
                             "kind": "require_passing_builds_to_merge",
                             "value" : 1
                          }
                        '

        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}/branch-restrictions" \
                     -H "Content-Type: application/json" \
                     -d ' {
                             "pattern": "master",
                             "kind": "push"
                          }
                        '
        ## Setup webhook
        curl -X POST -v -u "${bcUser}:${bcPass}" "https://api.bitbucket.org/2.0/repositories/${owner}/${repo}/hooks" \
             -H "Content-Type: application/json" \
             -d ' {
                     "description": "On prem Jenkins Webhook",
                     "url": "http://example.com/bitbucket-hook/",
                     "active": true,
                     "events": [
                       "repo:push",
                       "pullrequest:created"
                     ]
                  }'

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
