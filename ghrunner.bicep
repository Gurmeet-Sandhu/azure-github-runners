param adminUsername string
@secure()
param adminPassword string
@secure()
param GITHUB_TOKEN string
param REPO_OWNER string = 'Gurmeet-Sandhu'
param REPO_NAME string = 'azure-github-runner'

module runner 'br:ghatest.azurecr.io/bicep/modules/gh-runner:v1' = {
  name: 'ghrunner'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    GITHUB_TOKEN: GITHUB_TOKEN
    REPO_OWNER: REPO_OWNER
    REPO_NAME: REPO_NAME
  }
}
