 //this is a start of 3 tier webapp
// this is basic version no frills, 6 VMs 

param appprefix string = 'app'
param dbprefix string = 'db'
param webprefix string = 'web'
param appvmcount int = 2
param dbvmcount int = 2
param webvmcount int = 2
param prilocation string = resourceGroup().location
param adminuser string = 'appadmin'

@allowed([
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  ])
param vmsize string = 'Standard_B1s'

@secure()
@minLength(3)
@maxLength(12)
param appadminpass string

resource vnetpr 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnetpr1'
  location: prilocation
  properties: {
    addressSpace:{   
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
     subnets: [
      {
        name: ${webprefix}-PRsite
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
       ]
  }
}
resource webnwint 'Microsoft.Network/networkInterfaces@2020-11-01' = [for i in range(0,webvmcount): {
  name: ${webprefix}.i
 

  
}]
resource webvm 'Microsoft.Compute/virtualMachines@2020-12-01' = [for i in range(0,webvmcount): {
  name: 'webprefix${i}'
  location: location
  properties: {
    hardwareProfile: {
        vmSize: vmsize
      }
      osProfile: {
        computerName: 'web${i}'
        adminUsername: adminuser
        adminPassword: defaultpass
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
