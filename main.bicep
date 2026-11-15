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

output storageAccountName string = storageAccount.name
output websiteUrl string = storageAccount.properties.primaryEndpoints.blob
