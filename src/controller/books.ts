import express from 'express';

import { getUserByEmail } from '../db/users';

export const getBook = async (req: express.Request, res: express.Response) => {
  try {
    const { email, title } = req.params;
    const user = await getUserByEmail(email).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const book = user.books.find((book: { title: string }) => book.title === title);
    if (!book) {
      return res.status(404).json({ error: 'Book with this title does not exist' }).end();
    }

    return res.status(200).json(book).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const addBook = async (req: express.Request, res: express.Response) => {
  try {
    const { email, title } = req.params;
    const user = await getUserByEmail(email).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
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
    const { email, title } = req.params;
    const user = await getUserByEmail(email).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const bookIndex = user.books.findIndex((book: { title: string }) => book.title === title);

    if (bookIndex === -1) {
      return res.status(404).json({ error: 'Book with this title does not exist' }).end();
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
    const { email, title } = req.params;
    const user = await getUserByEmail(email).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const book = user.books.find((book: { title: string }) => book.title === title);

    if (!book) {
      return res.status(404).json({ error: 'Book with this title does not exist' }).end();
    }

    const record = req.body;

    // Check if category_id exists in book
    const categoryExists = book.categories.some((category: any) => category._id.toString() === record.category_id);
    if (!categoryExists) {
      return res.status(400).json({ error: 'Category with this id does not exist in book' }).end();
    }

    book.records.push(record);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const deleteRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { email, title, recordId } = req.params;
    const user = await getUserByEmail(email).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const book = user.books.find((book: { title: string }) => book.title === title);

    if (!book) {
      return res.status(404).json({ error: 'Book with this title does not exist' }).end();
    }

    const recordIndex = book.records.findIndex((record: { id: string }) => record.id === recordId);

    if (recordIndex === -1) {
      return res.status(404).json({ error: 'Record with this id does not exist' }).end();
    }

    book.records.splice(recordIndex, 1);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}