param subnetId string
param location string = resourceGroup().location
param ITstorageAccountId string 
param WebStorageAccountId string
param vnetId string
param linkServiceId string // This should be the ID of the App Service Plan or the App Service itself

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'pe-${subnetId}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${subnetId}'
        properties: {
          privateLinkServiceId: ITstorageAccountId
          groupIds: [
            'file'
          ]
          requestMessage: 'Please approve my connection'
        }
      }
    ]
  }
}
resource WebDbprivateEndPoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'pe-web-db-${subnetId}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-web-db-${subnetId}'
        properties: {
          privateLinkServiceId: WebStorageAccountId
          groupIds: [
            'blob'
          ]
          requestMessage: 'Please approve my connection'
        }
      }
    ]
  }
}
resource appservicePrivateEndPoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: 'pe-webapp-${subnetId}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-webapp-${subnetId}'
        properties: {
          privateLinkServiceId: linkServiceId
          // This should be the ID of the App Service Plan or the App Service itself
          groupIds: [
            'sites' // This group ID is for App Service
          ]
          requestMessage: 'Please approve my connection'
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2022-05-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
}

resource privareDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2022-05-01' = {
  name: 'vnet-link-${subnetId}'
  parent: privateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZoneWebDb 'Microsoft.Network/privateDnsZones@2022-05-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}
resource privareDnsLinkWebDb 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2022-05-01' = {
  name: 'vnet-link-web-db-${subnetId}'
  parent: privateDnsZoneWebDb
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
  


resource group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: privateEndPoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
resource WebDbgroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default-web-db'
  parent: WebDbprivateEndPoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default-web-db'
        properties: {
          privateDnsZoneId: privateDnsZoneWebDb.id
        }
      }
    ]
  }
}
