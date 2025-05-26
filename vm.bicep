
param adminUsername string
@secure()
param adminPassword string


param environmet string = 'IT'
param nic1Id string 
param nic2Id string

var nics = [
  {
    name: 'IT-NIC-1'
    id: nic1Id
  }
  {
    name: 'IT-NIC-2'
    id: nic2Id
  }
]



resource ITvm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, 2):{
  name: 'ITVM-${environmet}-${i}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'IT-VM-${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: 'OSDisk-App-${i}-${environmet}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  
    
  
}]

resource ITstorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' =  {
name: toLower('fshared${uniqueString(resourceGroup().id)}')
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' =  {
  name: 'default'
  parent: ITstorageAccount
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' =  {
  parent: fileService
  name: 'IT-fileshare'
  properties: {
    shareQuota: 100
    enabledProtocols: 'SMB'
  }
}
resource WebAppStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' =  {
  name: 'webapp${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource sqlService 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: 'sqlserver-${environmet}-${uniqueString(resourceGroup().id)}'

  location: resourceGroup().location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
 
}
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  name: 'sqldb-${environmet}-${uniqueString(resourceGroup().id)}'
  parent: sqlService
  location: resourceGroup().location
  properties: {
    
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
  }
}
output VmsIds array = [for i in range(0, 2): ITvm[i].id]

output FileShareids string = fileShare.id
output FileShareNames string = fileShare.name
output ITStorageAccountId string = ITstorageAccount.id
output WebAppStorageAccountId string = WebAppStorageAccount.id
