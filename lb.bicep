param location string = resourceGroup().location
param name string = 'LB-for-web-app'
param webappNicid string 

resource publicip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'

    
    idleTimeoutInMinutes: 4
  
  }
}
resource lb 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendConfig'
        properties: {
          publicIPAddress: {
            id: publicip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {}
      }
    ]
    loadBalancingRules: [
      {
        name: 'loadBalancingRule'
        properties: {
          frontendIPConfiguration: {
            id: '${publicip.id}/frontendIPConfigurations/frontendConfig'
          }
          backendAddressPool: {
            
            id: webappNicid
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
          loadDistribution: 'Default'
          
          
        }
      }
    ]
  }
}
