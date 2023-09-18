param adminUsername string
@secure()
param adminPassword string
@secure()
param PAT string
param REPO_OWNER string = 'Gurmeet-Sandhu'
param REPO_NAME string = 'azure-github-runners'

module runner 'br:ghatest.azurecr.io/bicep/modules/gh-runner:v1' = {
  name: 'runner'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    PAT: PAT
    REPO_OWNER: REPO_OWNER
    REPO_NAME: REPO_NAME
  }
}
