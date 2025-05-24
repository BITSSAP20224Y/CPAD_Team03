const express = require('express');
const app = express();
const expensesRoutes = require('./routes/expenses');

app.use(express.json());
app.use('/api/expenses', expensesRoutes);

const port = 3000;
app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
