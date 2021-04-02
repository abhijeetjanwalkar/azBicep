//create a availability set with x Fault Domain, user can define FDs as a parameter.
//Parameter FDCount is for Update Domain Count and FDCount is for Fault Domain Count

param FDCount int = 3
param UDCount int = 3

resource avaset 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: 'avasetx'
  location: resourceGroup().location
  properties:{
    platformUpdateDomainCount: UDCount
    platformFaultDomainCount: FDCount
  }
  }
