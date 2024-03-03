import { getCategories } from '../db/books';
import { getUserById, getUsers } from '../db/users';
import express from 'express';

export default (router: express.Router): void => {
  router.get('/test/users', (req, res) => {
    getUsers().select('+books.records').then((users) => {
      res.status(200).json(users).end();
    }).catch((error) => {
      console.log(error);
      res.status(400).json({ error: error.message }).end();
    });
  });
  router.get('/test/users/:userId', (req, res) => {
    const {userId} = req.params;
    getUserById(userId).select('+books.records +books.categories').then((users) => {
      res.status(200).json(users).end();
    }).catch((error) => {
      console.log(error);
      res.status(400).json({ error: error.message }).end();
    });
  });
  router.get('/test/categories', (req, res) => {
    getCategories().then((categories) => {
      res.status(200).json(categories).end();
    }).catch((error) => {
      console.log(error);
      res.status(400).json({ error: error.message }).end();
    });
  });
  router.get('/test2', (req, res) => res.send('test2'))
};