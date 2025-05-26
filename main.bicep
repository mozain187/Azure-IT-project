param adminname string = 'adminuser'
@secure()
param password string = 'unsecurePassword@'
param location string = resourceGroup().location



module vnet 'vnet.bicep' = {
  name: 'vnet'
  params: {
    environmet: 'IT'
  }
}

module lb 'lb.bicep' = {
  name: 'lb'
  params:{
   
    webappNicid: vnet.outputs.webappNicId
  }
}
module pe 'PE.bicep' = {
  name: 'pe'
  params: {
    vnetId: vnet.outputs.vnetId
    subnetId: vnet.outputs.PrivateEndSubnet
    location: location
    ITstorageAccountId: vmss.outputs.ITStorageAccountId
    WebStorageAccountId: vmss.outputs.WebAppStorageAccountId
    linkServiceId: webapp.outputs.servicePlanId
  }
}

module vmss 'vm.bicep' = {
  name: 'vmss'
  params: {
    adminUsername: adminname
    adminPassword: password
    nic1Id: vnet.outputs.nicg[0].id
    nic2Id: vnet.outputs.nicg[1].id
    
  }
}
module webapp 'webApp.bicep' = {
  name: 'webapp'
  params: {
    adminUsername: adminname
    adminPassword: password
    
  }
}




