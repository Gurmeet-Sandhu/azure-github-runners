param location string = 'uswest2'
param adminUsername string
@secure()
param adminPassword string

param GITHUB_TOKEN string
param REPO_OWNER string
param REPO_NAME string

resource vnet 'Microsoft.Network/virtualNetworks@2019-12-01' = {
  name: 'myVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2019-12-01' = {
  parent: vnet
  name: 'mySubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2019-12-01' = {
  name: 'myPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2019-12-01' = {
  name: 'myNIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'myIPConfig'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: 'myVM'
  location: location
  dependsOn: [
    nic
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    osProfile: {
      computerName: 'myVM'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource extension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: 'myVM/GitHubRunner'
  dependsOn: [
    vm
  ]
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      script: |
        #!/bin/bash
        
        # Install dependencies
        sudo apt-get update
        sudo apt-get install -y git
        
        # Download and configure the GitHub Runner
        mkdir actions-runner && cd actions-runner
        
        # Download the GitHub Runner package for Linux
        curl -O -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64-2.289.3.tar.gz
        
        # Extract the runner package
        tar xzf ./actions-runner-linux-x64-2.289.3.tar.gz
        
        # Configure the runner
        ./config.sh --url https://github.com/${REPO_OWNER}/${REPO_NAME} --token ${GITHUB_TOKEN} 
        
        # Start the runner as a service
        ./svc.sh install
        ./svc.sh start
      
   
      }
    protectedSettings: {
      script: 'YourCustomScript.sh'
    }
  }
}
