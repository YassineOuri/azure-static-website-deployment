const { app } = require('@azure/functions');
const { DefaultAzureCredential } = require('@azure/identity');
const { CosmosClient } = require('@azure/cosmos');

const client = new CosmosClient({
  endpoint: 'https://cosmos-db-static-website.documents.azure.com:443',
  aadCredentials: new DefaultAzureCredential({
    managedIdentityClientId : process.env.AZURE_CLIENT_ID
  }),
});
const container = client.database('portfolio_db').container('counters');

const ID = 'visitors';

app.http('visits', {
  methods: ['GET', 'POST'],
  authLevel: 'anonymous',
  route: 'visits',
  handler: async (request, context) => {
    try {
      if (request.method === 'POST') {
        try {
          const { resource } = await container
            .item(ID, ID)
            .patch([{ op: 'incr', path: '/count', value: 1 }]);
          return { status: 200, jsonBody: { count: resource.count } };
        } catch (err) {
          if (err.code !== 404) throw err;
          // First visit: create the item
          await container.items.create({ id: ID, count: 1 });
          return { status: 200, jsonBody: { count: 1 } };
        }
      }

      const { resource } = await container.item(ID, ID).read();
      return { status: 200, jsonBody: { count: resource?.count ?? 0 } };
    } catch (err) {
      context.error(err);
      return { status: 500, jsonBody: { error: 'Something went wrong' } };
    }
  },
});