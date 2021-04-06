//another attempt at bastion host
//Template to create AZ bastion host and dependant resources.
//no parameters, location same as RG


param vnet001 string = 'vnet001'
param location string = resourceGroup().location
param vnetaddspace string = '10.0.0.0/16'
param subnetaddspace string = '10.0.1.0/27'
param bashostname string = 'bastion001'

//create vnet
resource vnet1 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: vnet001
  location: location
  properties:{
    addressSpace:{
      addressPrefixes: [
        vnetaddspace
      ]
    }
  }

}

//create subnet
resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-08-01'= {
name: '${vnet1.name}/AzureBastionSubnet'
properties: {
  addressPrefix: subnetaddspace
}

}

//create Public IP
resource pip001 'Microsoft.Network/publicIPAddresses@2020-08-01'= {
  name: 'bas-pip'
  location: location
  sku:{
    tier:'Global'
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod: 'Static'

  }
}

//create bastion host
resource bas01 'Microsoft.Network/bastionHosts@2020-08-01'= {
  name: bashostname
  location: location
  properties:{
    ipConfigurations:[
     {
       name: 'ipconfig'
       properties: {
        subnet:{
          id:subnet1.id
        }
        publicIPAddress:{
          id:pip001.id
        }
      }
     } 
    ]
  }
}
