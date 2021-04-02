// First Bicep template to deploy a VM
// All values are hardcoded
// You need to have network interface pre-created and value added in the template 
// This will deploy a W2k19 VM with set user and a password and size Standard D2 v3 

//First Update: parameters for password, vmname and username, password 3 to 24 words and is a secure string
//Update 2: Added @allowed function for vmsize, and a default value.
//Still using already created nw interface need update there.
//update 3: trying to create nw interface first and then use is in the VM
//update 4: adding loop and deploying more than one VM, this template has hardcoded value of 2 VM to deploy
//update 5: adding parameter to ask user how many VMs to deploy

@minLength(3)
@maxLength(24)
@secure()
param adminpass string
// param vmname string
param username string
param location string = resourceGroup().location
param noofvms int = 3


@allowed([
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  ])
param vmsize string = 'Standard_B1s'

var subnet1 = 'abhisubnet1'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnet1'
  location: resourceGroup().location
  properties: {
    addressSpace:{
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
     subnets: [
      {
        name: subnet1
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
       ]
  }
}

resource nwinterface1 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0,noofvms): {
  name: 'mynwint${i}'
  //name: 'storageName${i}'
  location: resourceGroup().location
  properties:{
  ipConfigurations:[{
      name: 'ipconfig1${i}'
      properties:{
        subnet:{        
            id: '${vnet.id}/subnets/${subnet1}'
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }
  ]
}
}]

resource VM1 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0,noofvms): {
  name: 'myvm${i}'
  location: location
  properties: {
   hardwareProfile: {
     vmSize: vmsize
   }
   osProfile: {
     computerName: 'myvm${i}'
     adminUsername: username
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
           id: nwinterface1[i].id
          }
         
       ]
     }
 }
}]
