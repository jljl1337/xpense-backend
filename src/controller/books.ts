import express from 'express';

import { getUserById } from '../db/users';
import { ObjectId } from 'mongoose';

export const getBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    return res.status(200).json(book).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const addBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { title } = req.body;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    // Check if book already exists
    const bookExists = user.books.some((book: { title: string }) => book.title === title);
    if (bookExists) {
      return res.status(400).json({ error: 'Book with this title already exists' }).end();
    }

    const newBook = {
      title,
      categories: user.default_categories,
    }

    user.books.push(newBook);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const deleteBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const bookIndex = user.books.findIndex((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (bookIndex === -1) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    user.books.splice(bookIndex, 1);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const addRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const { category_id, date, amount, remark} = req.body;

    // Check if category_id exists in book
    const categoryExists = book.categories.some((category: any) => category._id.toString() === category_id);
    if (!categoryExists) {
      return res.status(400).json({ error: 'Category does not exist in book' }).end();
    }

    book.records.push({
      category_id,
      date,
      amount,
      remark,
    });

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, recordId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const recordIndex = book.records.findIndex((record: { id: string }) => record.id === recordId);

    if (recordIndex === -1) {
      return res.status(404).json({ error: 'Record does not exist' }).end();
    }

    const updatedRecord = req.body;
    book.records[recordIndex] = updatedRecord;

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const deleteRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, recordId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const recordIndex = book.records.findIndex((record: { id: string }) => record.id === recordId);

    if (recordIndex === -1) {
      return res.status(404).json({ error: 'Record does not exist' }).end();
    }

    book.records.splice(recordIndex, 1);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}