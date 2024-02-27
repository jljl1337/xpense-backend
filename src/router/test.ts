import { getCategories } from '../db/books';
import { getUsers } from '../db/users';
import express from 'express';

export default (router: express.Router): void => {
  router.get('/test/users', (req, res) => {
    getUsers().then((users) => {
      res.status(200).json(users).end();
    }).catch((error) => {
      console.log(error);
      res.sendStatus(400);
    });
  });
  router.get('/test/categories', (req, res) => {
    getCategories().then((categories) => {
      res.status(200).json(categories).end();
    }).catch((error) => {
      console.log(error);
      res.sendStatus(400);
    });
  });
  router.get('/test2', (req, res) => res.send('test2'))
};