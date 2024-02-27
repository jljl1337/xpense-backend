import express from 'express';

import { addUserCategory, deleteUserCategory, getUser, getUserCategories, updateUserCategory, updateUserInfo, updateUserPassword } from '../controller/users';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users', isAuthenticated, getUser);
  router.get('/users/categories', isAuthenticated, getUserCategories);
  router.post('/users/categories', isAuthenticated, addUserCategory);
  router.patch('/users', isAuthenticated, updateUserInfo);
  router.patch('/users/password', isAuthenticated, updateUserPassword);
  router.put('/users/categories', isAuthenticated, updateUserCategory);
  router.delete('/users/categories', isAuthenticated, deleteUserCategory);
};