import express from 'express';

import { addBook, addRecord, deleteBook, deleteRecord, getBook, updateBook, updateRecord } from '../controller/books';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.post('/users/:userId/books/', isAuthenticated, addBook);
  router.get('/users/:userId/books/:bookId', isAuthenticated, getBook);
  router.patch('/users/:userId/books/:bookId', isAuthenticated, updateBook);
  router.delete('/users/:userId/books/:bookId', isAuthenticated, deleteBook);

  // TODO: CUD for book categories

  router.post('/users/:userId/books/:bookId/records', isAuthenticated, addRecord);
  router.patch('/users/:userId/books/:bookId/records/:recordId', isAuthenticated, updateRecord);
  router.delete('/users/:userId/books/:bookId/records/:recordId', isAuthenticated, deleteRecord);
};