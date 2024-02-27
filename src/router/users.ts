import express from 'express';

import { addUserCategory, deleteUserCategory, getUser, getUserCategories, updateUserCategory, updateUserInfo, updateUserPassword } from '../controller/users';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users/:email', isAuthenticated, getUser);
  router.get('/users/:email/categories', isAuthenticated, getUserCategories);
  router.post('/users/:email/categories/:category', isAuthenticated, addUserCategory);
  router.patch('/users/:email', isAuthenticated, updateUserInfo);
  router.patch('/users/:email/password', isAuthenticated, updateUserPassword);
  router.put('/users/:email/categories/:category', isAuthenticated, updateUserCategory);
  router.delete('/users/:email/categories/:category', isAuthenticated, deleteUserCategory);
};