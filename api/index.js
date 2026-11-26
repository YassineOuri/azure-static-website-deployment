const { app } = require('@azure/functions');
const {DefaultAzureCredential} = require('@azure/identity')
const {CosmosClient} = require('@azure/cosmos')



const credential = new DefaultAzureCredential()
const client = new CosmosClient({
  endpoint: 'https://static-web-db-cosmos.documents.azure.com:443',
  aadCredentials: credential
})

const database = client.database('portfolio_db')
const container = database.container('counters')

app.http('visits', {
  methods: ['GET'],
  authLevel: 'anonymous',
  route: 'visits',
  handler: async () => {
    const id = 'visitors'
    const partitionKey = 'visitors'

    let response = await container.item(id, partitionKey).read()
    let count = response.resource.count;
    return { status: 200, jsonBody: { count }};
  }
});