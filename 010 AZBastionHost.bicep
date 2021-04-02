//Template to create AZ bastion host and dependant resources.
//no parameters, location same as RG
//For some reason getting this error tried all the simial options when did a manual deploy which wotked "code": "InvalidRequestFormat",
//"message": "Cannot parse the request."
//create a vnet and subnet
resource vnet1 'Microsoft.Network/virtualNetworks@2020-08-01' ={
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
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      
    ]
  }
}

//create a public ip
resource pip01 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: 'pip01'
  location: resourceGroup().location
  sku: {
    name:'Standard'
    tier: 'Global'
  }
  properties: {
    publicIPAllocationMethod:'Static'
    publicIPAddressVersion: 'IPv4'
    }
}
//create bastion

//resource bas001 'Microsoft.Network/bastionHosts@2018-08-01'
resource bas01 'Microsoft.Network/bastionHosts@2019-04-01' =  {
  name: 'bastion01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        id: 'IpConf'
        properties: {
          subnet: {
            id: '/subscriptions/ad7e5c4b-b5f4-4d4c-bb5d-9d4c6882675e/resourceGroups/azBicepRG/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/AzureBastionSubnet'
                  }
          publicIPAddress: {
            id: '/subscriptions/ad7e5c4b-b5f4-4d4c-bb5d-9d4c6882675e/resourceGroups/azBicepRG/providers/Microsoft.Network/publicIPAddresses/pip01'
                        }
        privateIPAllocationMethod: 'Static'
        }
      }
    ]

  }
}
