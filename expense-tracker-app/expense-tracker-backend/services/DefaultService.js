/* eslint-disable no-unused-vars */
const Service = require('./Service');

/**
* Get a list of expenses
*
* category String  (optional)
* from date  (optional)
* to date  (optional)
* limit Integer  (optional)
* offset Integer  (optional)
* returns List
* */
const expensesGET = ({ category, from, to, limit, offset }) => new Promise(
  async (resolve, reject) => {
    try {
      resolve(Service.successResponse({
        category,
        from,
        to,
        limit,
        offset,
      }));
    } catch (e) {
      reject(Service.rejectResponse(
        e.message || 'Invalid input',
        e.status || 405,
      ));
    }
  },
);
/**
* Delete an expense
*
* id String 
* no response value expected for this operation
* */
const expensesIdDELETE = ({ id }) => new Promise(
  async (resolve, reject) => {
    try {
      resolve(Service.successResponse({
        id,
      }));
    } catch (e) {
      reject(Service.rejectResponse(
        e.message || 'Invalid input',
        e.status || 405,
      ));
    }
  },
);
/**
* Get a specific expense
*
* id String 
* returns Expense
* */
const expensesIdGET = ({ id }) => new Promise(
  async (resolve, reject) => {
    try {
      resolve(Service.successResponse({
        id,
      }));
    } catch (e) {
      reject(Service.rejectResponse(
        e.message || 'Invalid input',
        e.status || 405,
      ));
    }
  },
);
/**
* Add a new expense
*
* newExpense NewExpense 
* returns Expense
* */
const expensesPOST = ({ newExpense }) => new Promise(
  async (resolve, reject) => {
    try {
      resolve(Service.successResponse({
        newExpense,
      }));
    } catch (e) {
      reject(Service.rejectResponse(
        e.message || 'Invalid input',
        e.status || 405,
      ));
    }
  },
);
/**
* Get monthly expense summary
*
* month String 
* returns Summary
* */
const summaryGET = ({ month }) => new Promise(
  async (resolve, reject) => {
    try {
      resolve(Service.successResponse({
        month,
      }));
    } catch (e) {
      reject(Service.rejectResponse(
        e.message || 'Invalid input',
        e.status || 405,
      ));
    }
  },
);

module.exports = {
  expensesGET,
  expensesIdDELETE,
  expensesIdGET,
  expensesPOST,
  summaryGET,
};
