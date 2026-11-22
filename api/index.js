const { app } = require('@azure/functions');

app.http('visits', {
  methods: ['GET'],
  authLevel: 'anonymous',
  route: 'visits',
  handler: async () => {
    // Placeholder: replace with a real value from storage later
    const count = 1248;

    return {
      status: 200,
      jsonBody: { count },
    };
  },
});