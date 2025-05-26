# Azure-IT-project
This project demonstrates a complete enterprise IT infrastructure deployment on Azure using Bicep
featuring:

Virtual Machines for IT operations

Azure Storage Accounts for file and queue services

Azure SQL Database integration

Secure networking with NSGs and private endpoints

Structured Role-Based Access Control (RBAC) for different teams using bash in the Cli:

IT Team: User Access Administrator + Reader

Dev Team: Contributor over specific resource group

Finance Team: Reader on the same resource group

Pricing estimation considerations

Deployment validation and error handling

🚀 Technologies:
Azure Bicep

Azure CLI

Azure RBAC

Virtual Networks, NSGs  

Azure Bastion

Azure SQL

Azure Storage

load Balancer 

vpn gateWay

ARM/Bicep Pricing Estimation




📂 used files:


  main.bicep
  vm.bicep
  PE.bicep
  vnet.bicep
  webApp.bicep
  lb.bicep


📊 Outcomes:
Automated deployment of scalable Azure infrastructure

Implemented granular RBAC policies

Pricing evaluation against budget constraints

Infrastructure as Code (IaC) best practices

 Lessons Learned: ^-^
Handling Azure deployment errors

Designing secure and cost-efficient Azure networks

Structuring enterprise-grade access controls

