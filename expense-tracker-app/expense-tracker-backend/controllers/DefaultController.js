/**
 * The DefaultController file is a very simple one, which does not need to be changed manually,
 * unless there's a case where business logic routes the request to an entity which is not
 * the service.
 * The heavy lifting of the Controller item is done in Request.js - that is where request
 * parameters are extracted and sent to the service, and where response is handled.
 */

const Controller = require('./Controller');
const service = require('../services/DefaultService');
const expensesGET = async (request, response) => {
  await Controller.handleRequest(request, response, service.expensesGET);
};

const expensesIdDELETE = async (request, response) => {
  await Controller.handleRequest(request, response, service.expensesIdDELETE);
};

const expensesIdGET = async (request, response) => {
  await Controller.handleRequest(request, response, service.expensesIdGET);
};

const expensesPOST = async (request, response) => {
  await Controller.handleRequest(request, response, service.expensesPOST);
};

const summaryGET = async (request, response) => {
  await Controller.handleRequest(request, response, service.summaryGET);
};


module.exports = {
  expensesGET,
  expensesIdDELETE,
  expensesIdGET,
  expensesPOST,
  summaryGET,
};
