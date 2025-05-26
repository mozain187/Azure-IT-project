
param environmet string
param location string = resourceGroup().location
param nsgname0 string = 'nsg-${environmet}-web'
param nsgname1 string = 'nsg-${environmet}-App'

 
param vnetName string = '${environmet}-vnet'
param subnetName string = '${environmet}-subnet-' 

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets:[
      {
        name: '${subnetName}web'
        properties:{
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg0.id
          }

        }
      }
      
       
      
      {
        name: '${subnetName}DB'
        properties:{addressPrefix:'10.0.3.0/24'
          networkSecurityGroup: {
            id: nsg2.id
          }
        }
        
      }
      {
        name: '${subnetName}IT'
        properties:{addressPrefix:'10.0.4.0/24'
          
        }
        
      }
      {
        name: '${subnetName}sales'
        properties:{addressPrefix:'10.0.5.0/24'
          
        }
        
      }
      {
        name:'AzureBastionSubnet'
        properties:{addressPrefix:'10.0.10.0/24'
          
        }
      }
      {
        name: 'GatewaySubnet'
         properties:{addressPrefix:'10.0.11.0/24'
         
        }
      }
      {
        name:'PrivateEndpoints'

        properties:{addressPrefix:'10.0.15.0/24'}
      }
    ]

  }
  tags: {
    
    name: 'webapp'

  }
  
}




resource nsg0 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgname0
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-Dns'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRanges: ['53']
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
        
      }
      {
        name: 'denyall'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }

    ]
  }
}
resource nsg2 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgname1
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-web-tier'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges:[
            '80'
            '443'
            '3306'

          ] 
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
        
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-Bastion-${environmet}-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}
resource azureBastion 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: 'bastion-${environmet}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: vnet.properties.subnets[4].id // AzureBastionSubnet
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

resource publicIpGateway 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-gateway-${environmet}-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    
  }
}
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: 'vpn-gateway-${environmet}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'   // VPN Gateway for encrypted site-to-site or P2S tunnels over public internet
    vpnType: 'RouteBased' // Dynamic route-based VPN — most modern deployments
    enableBgp: false       // No BGP routing needed for this infra
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          subnet: {
            id: vnet.properties.subnets[5].id // GatewaySubnet
          }
          publicIPAddress: {
            id: publicIpGateway.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(0,2): {
  name: 'nic-${environmet}-${uniqueString(resourceGroup().id)}-${i}'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-${environmet}-${uniqueString(resourceGroup().id)}-${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[2].id
          }
         
        }
      }
    ]
  }
}]
resource webappNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'webapp-nic--${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-webapp-${uniqueString(resourceGroup().id)}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          
        }
      }
    ]

  }
}


output nsgg object[] = [
  { id: nsg0.id }
  { id: nsg2.id }
]
output nicg object[] = [
  { id: nic[0].id }
  { id: nic[1].id }
]
output vnetId string = vnet.id
output vpnGatewayId string = vpnGateway.id
output PrivateEndSubnet string = vnet.properties.subnets[6].id
output webappNicId string = webappNic.id
