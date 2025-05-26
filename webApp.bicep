param adminUsername string
@secure()
param adminPassword string

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'asp-${environment().name}-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  properties: {
    reserved: true // Indicates a Linux App Service Plan
  }
 
}


resource AppService 'Microsoft.Web/sites@2024-04-01' = {
  name: 'webapp-${environment().name}-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '18-lts'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
 
}
resource config 'Microsoft.Web/sites/config@2024-04-01' = {
  name: 'web'
  parent: AppService
  
  properties: {
    linuxFxVersion: 'NODE|18-lts'
    appSettings: [
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '18-lts'
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
    ]
    ftpsState: 'Disabled' // Disable FTP for security
    connectionStrings: [
      {
        name: 'DefaultConnection'
        connectionString: 'Server=tcp:sqlserver-${environment().name}-${uniqueString(resourceGroup().id)}.database.windows.net,1433;Initial Catalog=webappdb;Persist Security Info=False;User ID=${adminUsername};Password=${adminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        type: 'SQLAzure'
      }
    ]
  }
}
  output servicePlanId string = appServicePlan.id
