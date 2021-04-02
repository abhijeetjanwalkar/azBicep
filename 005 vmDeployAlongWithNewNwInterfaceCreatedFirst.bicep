// First Bicep template to deploy a VM
// All values are hardcoded
// You need to have network interface pre-created and value added in the template 
// This will deploy a W2k19 VM with set user and a password and size Standard D2 v3 

//First Update: parameters for password, vmname and username, password 3 to 24 words and is a secure string
//Update 2: Added @allowed function for vmsize, and a default value.
//Still using already created nw interface need update there.
//update 3: trying to create nw interface first and then use is in the VM

@minLength(3)
@maxLength(24)
@secure()
param adminpass string = 'M@zzP@ss123'
param vmname string
param username string
param location string = resourceGroup().location

@allowed([
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  ])
param vmsize string = 'Standard_B1s'

resource nwinterface1 'Microsoft.Network/networkInterfaces@2020-08-01' ={
  name: vmname
  location: resourceGroup().location
  properties:{
  ipConfigurations:[{
      name: 'ipconfig1'
      properties:{
        subnet:{        
                id: '/subscriptions/ad7e5c4b-b5f4-4d4c-bb5d-9d4c6882675e/resourceGroups/azBicepRG/providers/Microsoft.Network/virtualNetworks/abhivnet1CUS/subnets/abhisubnet1'
        }
        privateIPAllocationMethod: 'Dynamic'
      }
    }
  ]
}
}

resource VM1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
 name: vmname
 location: location
 properties: {
   hardwareProfile: {
     vmSize: vmsize
   }
   osProfile: {
     computerName: vmname
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
           id: nwinterface1.id
          }
         
       ]
     }
 }
}
