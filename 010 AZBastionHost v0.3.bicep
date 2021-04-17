// this is first attemp to make multi-tier application deploymnet
// in first phase primary site will be built.
// it is scoped to a resource group
//naming conventions
// Site --> pr - primary site, prdr - Disaster recovery for primary site, ha - high availability site, hadr DR site for HA side
// all Azure entities
// <site>-<purpose>-<entity>-<number>
//purpose - Tier01 / Tier02 / Tier03 /Common
//entity - VM / vNet / nw interface / extra disk / subnet / ILB / ELB (to be added once identified)
//number - starting from 0

//parameters
@allowed([
  'pr'
  'prdr'
  'ha'
  'hadr'
])
param prsite string = 'pr'
param prdrsite string = 'prdr'
param hasite string = 'ha'
param hadrsite string = 'hadr'

param location string = resourceGroup().location
param prnwaddprefix string = '10.10.0.0/16'
@allowed([
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  ])
param vmsize string = 'Standard_B1s'

param appvmcount int = 2
param dbvmcount int = 2
param webvmcount int = 2
param adminuser string = 'appuser'
@secure()
@minLength(8)
@maxLength(12)
param adminpass string = 'S3cuR3P@ss'

//variables
var tier01 = 'web'
var tier02 = 'db'
var tier03 = 'app'

// build common dependancies for primary prsite
//build 2 pips
//pip 01 for web servers
resource prcompip01 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${prsite}-com-pip-01'
  location: location
  sku:{
     name: 'Basic'
     tier: 'Regional'
  }
  properties:{
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
      }
}


//pip 02 for Bastion servers
resource prcompip02 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${prsite}-com-pip-02'
  location: location
  sku:{
     name:'Standard'
     tier: 'Regional'
  }
  properties:{
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
      }
}

//build bastion host
resource prcombas01 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: '${prsite}-com-bas-01'
  location: location
  properties:{
    ipConfigurations:[ {
      name: '${prsite}-com-pipipconfig-01'
      properties:{
        subnet:{
          id: '${prcomvnet1.id}/subnets/AzureBastionSubnet'
          }
        privateIPAllocationMethod:'Dynamic'
        publicIPAddress:{
          id: prcompip02.id
        }
      }
         }
    ]
  }
}
// build vnet and 3 tier networks for primary prsite

resource prcomvnet1 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: '${prsite}-com-vnet-01'
  location: resourceGroup().location
  properties: {
    addressSpace:{
      addressPrefixes: [
        prnwaddprefix
      ]
    }
     subnets: [
      {
        name: '${prsite}-${tier01}-subnet-01'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
      {
        name: '${prsite}-${tier02}-subnet-01'
        properties: {
          addressPrefix: '10.10.2.0/24'  
        }
      }
      {
        name: '${prsite}-${tier03}-subnet-01'
        properties: {
          addressPrefix: '10.10.3.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.10.0.0/27'
        }
      }
       ]
  }
}

//build web VM and its dependancies
//build dependancies - network interfaces
resource prwebnwint 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0,webvmcount): {
  name: '${prsite}-${tier01}-nwint-${i}'
  location: location
  properties:{
  ipConfigurations:[{
      name: '${prsite}-${tier01}-ipconfig-${i}'
      properties:{
        subnet:{        
            id: '${prcomvnet1.id}/subnets/${prsite}-${tier01}-subnet-01'
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }
  ]
}
}]
//build web VM
resource prwebvm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0,webvmcount): {
  name: '${prsite}-${tier01}-vm-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: '${prsite}-${tier01}-vm-${i}'
      adminUsername: adminuser
      adminPassword: adminpass
    }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2019-Datacenter'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
        }
       }
      networkProfile: {
        networkInterfaces: [
          {
            id: prwebnwint[i].id
           }
         ]
      }
  }
 }]
 
 //create internal LB for web VMs.
 //resource prweblb01 'Microsoft.Network/loadBalancers@2020-11-01': {
 //  name: '${prsite}-${tier01}-ilb-${i}'
 //  location: location
 //  properties: {
 //    backendAddressPools:[
 //      
 //   ]
//
//   }
//   
// }
 //build db VM and its dependancies
//build dependancies - network interfaces
resource prdbnwint 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0,dbvmcount): {
  name: '${prsite}-${tier02}-nwint-${i}'
  location: location
  properties:{
  ipConfigurations:[{
      name: '${prsite}-${tier02}-ipconfig-${i}'
      properties:{
        subnet:{        
            id: '${prcomvnet1.id}/subnets/${prsite}-${tier02}-subnet-01'
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }
  ]
}
}]
//build DB VM
resource prdbvm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0,dbvmcount): {
  name: '${prsite}-${tier02}-vm-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: '${prsite}-${tier02}-vm-${i}'
      adminUsername: adminuser
      adminPassword: adminpass
    }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2019-Datacenter'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
        }
       }
      networkProfile: {
        networkInterfaces: [
          {
            id: prdbnwint[i].id
           }
         ]
      }
  }
 }]
 
 //build app VM and its dependancies
//build dependancies - network interfaces
resource prappnwint 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0,appvmcount): {
  name: '${prsite}-${tier03}-nwint-${i}'
  location: location
  properties:{
  ipConfigurations:[{
      name: '${prsite}-${tier03}-ipconfig-${i}'
      properties:{
        subnet:{        
            id: '${prcomvnet1.id}/subnets/${prsite}-${tier03}-subnet-01'
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }
  ]
}
}]
//build App VM
resource prappvm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0,appvmcount): {
  name: '${prsite}-${tier03}-vm-${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: '${prsite}-${tier03}-vm-${i}'
      adminUsername: adminuser
      adminPassword: adminpass
    }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2019-Datacenter'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
        }
       }
      networkProfile: {
        networkInterfaces: [
          {
            id: prappnwint[i].id
           }
         ]
      }
  }
 }]
 