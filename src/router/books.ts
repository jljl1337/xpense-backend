import express from 'express';

import { addBook, addRecord, deleteBook, deleteRecord, getBook } from '../controller/books';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users/:email/books/:title', isAuthenticated, getBook);
  router.post('/users/:email/books/:title', isAuthenticated, addBook);
  router.post('/users/:email/books/:title/records', isAuthenticated, addRecord);
  router.delete('/users/:email/books/:title', isAuthenticated, deleteBook);
  router.delete('/users/:email/books/:title/records/:recordId', isAuthenticated, deleteRecord);
};