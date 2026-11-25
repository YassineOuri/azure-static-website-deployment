const { app } = require('@azure/functions');
const sql = require('mssql')



let poolPromise;
function getPool() {
  if(!poolPromise) {
    poolPromise = new sql.ConnectionPool(process.env.SQL_CONNECTION_STRING)
      .connect()
      .catch((err) => {
        poolPromise = undefined;
        throw err;
      })
  }

  return poolPromise;
}

app.http('visits', {
  methods: ['GET'],
  authLevel: 'anonymous',
  route: 'visits',
  handler: async () => {
    try {
      const pool = await getPool();
      const result = await pool
        .request()
        .query('SELECT [count] FROM dbo.visits WHERE id = 1');
      const count = result.recordset[0]?.count ?? 0;
      return { status: 200, jsonBody: { count }};
    } catch (err) {
      context.error('Failed to read visits', err);
      return { status: 500, jsonBody: { error: 'Could not read visit count' } };
    }
  }
});