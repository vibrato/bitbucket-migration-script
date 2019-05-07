# Bitbucket server repository migration script to Bitbucket Cloud

## This script is to migrate Bitbucket server repository only (not user and permission) to Bitbucket cloud

### Prerequisite
1. Add a SSH Key into your bitbucket server user account
2. Have all the repository names that you want to migrate in repo.txt

### Usage
./bitbucket-migrate.sh repos.txt

### Output
This script will git clone all the repositories from the list in repo.txt and push it (including all the branches and history) to the new repository in Bitbucket Cloud one by one after creating the repository using the Bitbucket Cloud RESTful Api

### Script steps
1. git clone a repo using ssh
2. create a new repo (using the same name) in Bitbucket Cloud using RESTful api
3. git push to the new repo in Bitbucket Cloud
4. Clean up the directory
