// First Bicep template to deploy a VM
// All values are hardcoded
// You need to have network interface pre-created and value added in the template 
// This will deploy a W2k19 VM with set user and a password and size Standard D2 v3 

//First Update: parameters for password, vmname and username, password 3 to 24 words and is a secure string

@minLength(3)
@maxLength(24)
@secure()
param adminpass string
param vmname string
param username string
param location string = resourceGroup().location

resource VM1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
 name: vmname
 location: location
 properties: {
   hardwareProfile: {
     vmSize: 'Standard_B1s'
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
           id: '/subscriptions/ad7e5c4b-b5f4-4d4c-bb5d-9d4c6882675e/resourceGroups/azBicepRG/providers/Microsoft.Network/networkInterfaces/abhinetinterface001'
          }
         
       ]
     }
 }
}
