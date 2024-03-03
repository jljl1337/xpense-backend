import express from 'express';

import { getUserById } from '../db/users';
import { ObjectId } from 'mongoose';

export const addBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { title } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    // Check if book already exists
    const bookExists = user.books.some((book: { title: string }) => book.title === title);
    if (bookExists) {
      return res.status(400).json({ error: 'Book with this title already exists.' }).end();
    }

    const newBook = {
      title,
      categories: user.defaultCategories,
    }

    user.books.push(newBook);

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const getBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    return res.status(200).json(book).end();
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const { newTitle } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    // check if book with new title already exists
    const bookExists = user.books.some((book: { title: string }) => book.title === newTitle);
    if (bookExists) {
      return res.status(400).json({ error: 'Book with this title already exists.' }).end();
    }

    book.title = newTitle;

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const deleteBook = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const bookIndex = user.books.findIndex((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (bookIndex === -1) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    user.books.splice(bookIndex, 1);

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const addBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const { name } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const categoryExists = book.categories.some((category: any) => category.name === name);
    if (categoryExists) {
      return res.status(400).json({ error: 'Category with this name already exists in this book.' }).end();
    }

    book.categories.push({ name });

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, categoryId } = req.params;
    const { newName } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const categoryIndex = book.categories.findIndex((category: { _id: ObjectId }) => category._id.toString() === categoryId);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category does not exist.' }).end();
    }

    book.categories[categoryIndex].name = newName;

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const deleteBookCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, categoryId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);
    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const categoryIndex = book.categories.findIndex((category: { _id: ObjectId }) => category._id.toString() === categoryId);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category does not exist.' }).end();
    }

    // Check if category is used in any record
    const categoryUsed = book.records.some((record: { categoryId: string }) => record.categoryId === categoryId);
    if (categoryUsed) {
      return res.status(400).json({ error: 'Category is used in records. Please remove all related records or change the category before removing the category.' }).end();
    }

    book.categories.splice(categoryIndex, 1);

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const addRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const { categoryId, date, amount, remark} = req.body;

    // Check if categoryId exists in book
    const categoryExists = book.categories.some((category: any) => category._id.toString() === categoryId);
    if (!categoryExists) {
      return res.status(400).json({ error: 'Category does not exist in book.' }).end();
    }

    book.records.push({
      categoryId,
      date,
      amount,
      remark,
    });

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, recordId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const recordIndex = book.records.findIndex((record: { id: string }) => record.id === recordId);

    if (recordIndex === -1) {
      return res.status(404).json({ error: 'Record does not exist.' }).end();
    }

    for (const key in req.body) {

      if (key === 'categoryId') {
        const categoryExists = book.categories.some((category: any) => category._id.toString() === req.body.categoryId);
        if (!categoryExists) {
          return res.status(400).json({ error: 'Category does not exist in book.' }).end();
        }
      }

      if (Object.prototype.hasOwnProperty.call(req.body, key)) {
        book.records[recordIndex][key] = req.body[key];
      }
    }

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const deleteRecord = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, bookId, recordId } = req.params;
    const user = await getUserById(userId).select('+books.records');

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const book = user.books.find((book: { _id: ObjectId }) => book._id.toString() === bookId);

    if (!book) {
      return res.status(404).json({ error: 'Book does not exist.' }).end();
    }

    const recordIndex = book.records.findIndex((record: { id: string }) => record.id === recordId);

    if (recordIndex === -1) {
      return res.status(404).json({ error: 'Record does not exist.' }).end();
    }

    book.records.splice(recordIndex, 1);

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}