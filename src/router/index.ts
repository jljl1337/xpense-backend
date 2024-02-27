import express from 'express';

import auth from './auth';
import test from './test';
import users from './users';
import books from './books';

const router = express.Router();

export default (): express.Router => {
  auth(router);
  test(router);
  users(router);
  books(router);

  return router;
};