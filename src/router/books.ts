import express from 'express';

import { addBook, addBookCategory, addRecord, deleteBook, deleteBookCategory, deleteRecord, getBook, updateBook, updateBookCategory, updateRecord } from '../controller/books';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.post('/users/:userId/books/', isAuthenticated, addBook);
  router.get('/users/:userId/books/:bookId', isAuthenticated, getBook);
  router.patch('/users/:userId/books/:bookId', isAuthenticated, updateBook);
  router.delete('/users/:userId/books/:bookId', isAuthenticated, deleteBook);

  router.post('/users/:userId/books/:bookId/categories', isAuthenticated, addBookCategory);
  router.patch('/users/:userId/books/:bookId/categories/:categoryId', isAuthenticated, updateBookCategory);
  router.delete('/users/:userId/books/:bookId/categories/:categoryId', isAuthenticated, deleteBookCategory);

  router.post('/users/:userId/books/:bookId/records', isAuthenticated, addRecord);
  router.patch('/users/:userId/books/:bookId/records/:recordId', isAuthenticated, updateRecord);
  router.delete('/users/:userId/books/:bookId/records/:recordId', isAuthenticated, deleteRecord);
};