
@description('Primary region for all Azure resources')
@minLength(1)
param location string = resourceGroup().location 

@description('A unique token used for resource name generation.')
@minLength(3)
param resourceToken string = toLower(uniqueString(subscription().id, location))

@description('A globally unique name for your deployed function app.')
param resourceName string = 'cosmos-${resourceToken}'


resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: resourceName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capabilities: []
    consistencyPolicy: {
      defaultConsistencyLevel: 'BoundedStaleness'
      maxIntervalInSeconds: 10
      maxStalenessPrefix: 200
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    disableKeyBasedMetadataWriteAccess: false
    disableLocalAuth: false
    enableAnalyticalStorage: false
    enableAutomaticFailover: false
    enableFreeTier: true
    enableMultipleWriteLocations: false
    ipRules: []
    isVirtualNetworkFilterEnabled: false
    locations: [
      {
        failoverPriority: 0
        isZoneRedundant: false
        locationName: location
      }
    ]
    networkAclBypass: 'None'
    networkAclBypassResourceIds: []
    publicNetworkAccess: 'Enabled'
    virtualNetworkRules: []
  }
}


resource sqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: databaseAccount
  name: 'portfolio_db'
  properties: {
    resource: {
      id: 'portfolio_db'
    }
    options: {}
  }
}

resource countersContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: sqlDatabase
  name: 'counters'
  properties: {
    resource: {
      id: 'counters'
      partitionKey: {
        paths: [
          '/visitors'
        ]
        kind: 'Hash'
        version: 2
      }
    }
    options: {}
  }
}


output cosmosEndpoint string = databaseAccount.properties.documentEndpoint
output cosmosName string = databaseAccount.name
