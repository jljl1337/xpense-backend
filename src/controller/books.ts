import express from 'express';

import { getUserById } from '../db/users';
import { ObjectId } from 'mongoose';

export const addBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { title } = req.body;
    const user = await getUserById(userId);

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

export const updateBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const { new_title } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    book.title = new_title;

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
    const user = await getUserById(userId);

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

export const addBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const { name } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const categoryExists = book.categories.some((category: any) => category.name === name);
    if (categoryExists) {
      return res.status(400).json({ error: 'Category with this name already exists in this book' }).end();
    }

    book.categories.push({ name });

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, categoryId } = req.params;
    const { new_name } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const categoryIndex = book.categories.findIndex((category: { _id: ObjectId }) => category._id.toString() === categoryId);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category does not exist' }).end();
    }

    book.categories[categoryIndex].name = new_name;

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const deleteBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, categoryId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist' }).end();
    }

    const categoryIndex = book.categories.findIndex((category: { _id: ObjectId }) => category._id.toString() === categoryId);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category does not exist' }).end();
    }

    book.categories.splice(categoryIndex, 1);

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

    for (const key in req.body) {

      if (key === 'category_id') {
        const categoryExists = book.categories.some((category: any) => category._id.toString() === req.body.category_id);
        if (!categoryExists) {
          return res.status(400).json({ error: 'Category does not exist in book' }).end();
        }
      }

      if (Object.prototype.hasOwnProperty.call(req.body, key)) {
        book.records[recordIndex][key] = req.body[key];
      }
    }

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