const express = require('express');
const router = express.Router();
const service = require('../controllers/ExpensesService');

router.post('/', (req, res) => {
  const newExpense = service.addExpense(req.body);
  res.status(201).json(newExpense);
  console.log("POST /api/expenses hit");
  console.log("🔍 Received expense:", req.body);
});

router.get('/', (req, res) => {
  const allExpenses = service.getAllExpenses();
  res.json(allExpenses);
});

router.get('/month/:month', (req, res) => {
  const month = req.params.month;
  const filtered = service.getAllExpenses().filter(exp =>
    exp.createdAt?.startsWith(month)
  );
  res.json(filtered);
});


router.get('/:id', (req, res) => {
  const expense = service.getExpenseById(req.params.id);
  if (expense) res.json(expense);
  else res.status(404).json({ message: 'Expense not found' });
});

router.put('/:id', (req, res) => {
    const updatedExpense = service.updateExpense(req.params.id, req.body);
    if (updatedExpense) {
      res.json(updatedExpense);
    } else {
      res.status(404).json({ message: 'Expense not found' });
    }
  });  

router.delete('/:id', (req, res) => {
  const success = service.deleteExpense(req.params.id);
  if (success) res.json({ message: 'Deleted successfully' });
  else res.status(404).json({ message: 'Expense not found' });
});

router.get('/summary/monthly', (req, res) => {
  const { month } = req.query; // Expect "2025-07"
  const summary = {
    total: 0,
    byCategory: {}
  };

  const filtered = service.getAllExpenses().filter(exp => {
    const expenseMonth = new Date(exp.createdAt).toISOString().slice(0, 7);
    return expenseMonth === month;
  });

  for (const exp of filtered) {
    const amount = Number(exp.amount);
    summary.total += amount;
    summary.byCategory[exp.category] = (summary.byCategory[exp.category] || 0) + amount;
  }

  res.json(summary);
});

  

module.exports = router;
