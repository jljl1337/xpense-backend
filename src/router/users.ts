import express from 'express';

import { getUser, updateUserInfo, updateUserPassword } from '../controller/users';
import { isAuthenticated } from '../middleware';

export default (router: express.Router): void => {
  router.get('/users/:email', isAuthenticated, getUser);
  router.patch('/users/:email', isAuthenticated, updateUserInfo);
  router.patch('/users/:email/password', isAuthenticated, updateUserPassword);
};