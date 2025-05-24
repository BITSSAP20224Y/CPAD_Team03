let expenses = [];
let idCounter = 1;

module.exports = {
  addExpense: (expenseData) => {
    const newExpense = {
      id: idCounter.toString(),
      ...expenseData,
      createdAt: expenseData.createdAt || new Date().toISOString(),
    };
    idCounter++;
    expenses.push(newExpense);
    return newExpense;
  },
  
  getAllExpenses: () => expenses,

  getExpenseById: (id) => expenses.find(exp => exp.id === id),

  deleteExpense: (id) => {
    const index = expenses.findIndex(exp => exp.id === id);
    if (index !== -1) {
      expenses.splice(index, 1);
      return true;
    }
    return false;
  },

  updateExpense: (id, updateData) => {
    const index = expenses.findIndex(exp => exp.id === id);
    if (index !== -1) {
      expenses[index] = {
        ...expenses[index],
        ...updateData,
        updatedAt: new Date().toISOString(),
      };
      return expenses[index];
    }
    return null;
  },

  getMonthlySummary: (monthString) => {
    const summary = {
      total: 0,
      byCategory: {}
    };
  
    expenses.forEach(exp => {
      const expenseMonth = new Date(exp.createdAt).toISOString().slice(0, 7); // ✅ safe parsing
      if (expenseMonth === monthString) {
        const amount = Number(exp.amount);
        summary.total += amount;
    
        if (summary.byCategory[exp.category]) {
          summary.byCategory[exp.category] += amount;
        } else {
          summary.byCategory[exp.category] = amount;
        }
      }
    });    
  
    return summary;
  }
  
  
};
