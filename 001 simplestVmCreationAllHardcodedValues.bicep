 // First Bicep template to deploy a VM
 // All values are hardcoded
 // You need to have network interface pre-created and value added in the template 
 // This will deploy a W2k19 VM with set user and a password and size Standard D2 v3 and create a new disk of 100 GiB
 
 
 resource VM1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'abhiVM1'
  location: 'eastus'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
    }
    osProfile: {
      computerName: 'abhiVM1'
      adminUsername: 'abhijeet'
      adminPassword: 'M@zaP#$$3467'
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
        dataDisks: [
          {
            diskSizeGB: 100
            lun: 0
            createOption: 'Empty'
          }
        ]
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: '/subscriptions/ad7e5c4b-b5f4-4d4c-bb5d-9d4c6882675e/resourceGroups/azBicepRG/providers/Microsoft.Network/networkInterfaces/abhinetinterface1'
           }
          
        ]
      }
  }
}
