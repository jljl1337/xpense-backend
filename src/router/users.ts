import express from 'express';

import { addUserCategory, deleteUserCategory, getUser, getUserCategories, updateUserCategory, updateUserInfo, updateUserPassword } from '../controller/users';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users/:userId', isAuthenticated, getUser);
  router.patch('/users/:userId', isAuthenticated, updateUserInfo);
  router.patch('/users/:userId/password', isAuthenticated, updateUserPassword);

  router.post('/users/:userId/categories', isAuthenticated, addUserCategory);
  router.get('/users/:userId/categories', isAuthenticated, getUserCategories);
  router.put('/users/:userId/categories/:categoryId', isAuthenticated, updateUserCategory);
  router.delete('/users/:userId/categories/:categoryId', isAuthenticated, deleteUserCategory);
};