param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param storageAccountName string = 'stweb${uniqueString(resourceGroup().id)}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku : {
    name: 'Standard_LRS'
  }

  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
  }
}



resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-08-01' = {
    parent: storageAccount
    name: 'default'
    properties: {
      staticWebsite: {
        enabled: true
        indexDocument: 'index.html'
        errorDocument404Path: '404.html'
      }
    }
}


module storageAccountModule './storage_account.bicep' = {
  name: 'storageDeploy'
}

module cosmosDbModule './database.bicep' = {
  name : 'cosmosDeploy'
}


module functionAppModule './functions.bicep' = {
  name: 'functionsDeploy'
  params: {
    cosmosDBName : cosmosDbModule.outputs.cosmosName
    cosmosEndpoint : cosmosDbModule.outputs.cosmosEndpoint
    storageAccountName: storageAccount.name
    location: resourceGroup().location
    static_site_origin: endsWith(storageAccount.properties.primaryEndpoints.web, '/') ? take(storageAccount.properties.primaryEndpoints.web, length(storageAccount.properties.primaryEndpoints.web) - 1) : storageAccount.properties.primaryEndpoints.web
  }
}

output storageAccountName string = storageAccount.name
output websiteUrl string = storageAccount.properties.primaryEndpoints.web
output functionAppEndpoint string = functionAppModule.outputs.functionAppEndpoint
output functionAppName string = functionAppModule.outputs.functionAppName
output cosmosEndpoint string = cosmosDbModule.outputs.cosmosEndpoint
