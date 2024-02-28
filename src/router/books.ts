import express from 'express';

import { addBook, addRecord, deleteBook, deleteRecord, getBook } from '../controller/books';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users/:userId/books/:bookId', isAuthenticated, getBook);
  router.post('/users/:userId/books/', isAuthenticated, addBook);
  router.delete('/users/:userId/books/:bookId', isAuthenticated, deleteBook);

  router.post('/users/:userId/books/:bookId/records', isAuthenticated, addRecord);
  router.delete('/users/:userId/books/:bookId/records/:recordId', isAuthenticated, deleteRecord);
};