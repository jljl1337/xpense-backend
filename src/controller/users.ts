import express from 'express';
import bycrypt from 'bcrypt';

import { getUserByEmail, getUserById } from '../db/users';
import { meetPasswordRequirements } from '../helper';
import { ObjectId } from 'mongoose';

const SALT_ROUNDS = Number(process.env.SALT_ROUNDS);

export const getUser = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateUserInfo = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { newUsername, newEmail  } = req.body;
    const userPromise = getUserById(userId);

    if (!newUsername && !newEmail) {
      return res.status(400).json({ error: 'New username or email is required.' }).end();
    }

    const user = await userPromise;

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    if (newUsername) {
      user.username = newUsername;
    }

    if (newEmail) {
      const other_user = await getUserByEmail(newEmail);
      if (other_user && other_user._id.toString() !== userId) {
        return res.status(400).json({ error: 'User with this email already exists.' }).end();
      }

      user.email = newEmail;
    }

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateUserPassword = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { oldPassword, newPassword  } = req.body;
    const userPromise = getUserById(userId).select('+authentication.password +authentication.tokens');

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Old and new password are required.' }).end();
    }

    const user = await userPromise;

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist.' }).end();
    }

    if (!meetPasswordRequirements(newPassword)) {
      return res.status(400).json({ error: 'Password does not meet requirements.' }).end();
    }

    bycrypt.compare(oldPassword, user.authentication.password as string, async (err: Error, result: boolean) => {
      if (!result) {
        return res.status(400).json({ error: 'Old password is incorrect.' }).end();
      }

      bycrypt.hash(newPassword, SALT_ROUNDS, async (err: Error, hash: string) => {
        if (err) {
          return res.status(400).json({ error: err.message }).end();
        }

        user.authentication.password = hash;

        // Remove all tokens
        user.authentication.tokens = [];

        await user.save();

        return res.sendStatus(200);
      });
    });
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const addUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { category } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const categoryExist = user.books.some((categoryObject: { name: string }) => categoryObject.name === category);
    if (categoryExist) {
      return res.status(400).json({ error: 'Category already exists.' }).end();
    }

    user.defaultCategories.push({ name: category });

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

// TODO: can removed?
export const getUserCategories = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    return res.status(200).json(user.defaultCategories).end();
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const updateUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, categoryId } = req.params;
    const { newCategory } = req.body;

    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }
    
    const categoryIndex = user.defaultCategories.findIndex((categoryObject: { _id: ObjectId }) => categoryObject._id.toString() === categoryId);

    if (categoryIndex === -1) {
      return res.status(400).json({ error: 'Category does not exist.' }).end();
    }

    user.defaultCategories[categoryIndex].name = newCategory;

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}

export const deleteUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, categoryId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist.' }).end();
    }

    const categoryIndex = user.defaultCategories.findIndex((categoryObject: { _id: ObjectId }) => categoryObject._id.toString() === categoryId);

    if (categoryIndex === -1) {
      return res.status(400).json({ error: 'Category does not exist.' }).end();
    }

    user.defaultCategories.splice(categoryIndex, 1);

    await user.save();

    return res.sendStatus(200);
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}