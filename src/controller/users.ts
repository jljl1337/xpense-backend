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
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateUserInfo = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { new_username, new_email  } = req.body;
    const userPromise = getUserById(userId);

    if (!new_username && !new_email) {
      return res.status(400).json({ error: 'New username or email is required' }).end();
    }

    const user = await userPromise;

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    if (new_username) {
      user.username = new_username;
    }

    if (new_email) {
      const other_user = await getUserByEmail(new_email);
      if (other_user) {
        return res.status(400).json({ error: 'User with this email already exists' }).end();
      }

      user.email = new_email;
    }

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateUserPassword = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { old_password, new_password  } = req.body;
    const userPromise = getUserById(userId).select('+authentication.password +authentication.tokens');

    if (!old_password || !new_password) {
      return res.status(400).json({ error: 'Old and new password are required' }).end();
    }

    const user = await userPromise;

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    if (!meetPasswordRequirements(new_password)) {
      return res.status(400).json({ error: 'Password does not meet requirements' }).end();
    }

    bycrypt.compare(old_password, user.authentication.password as string, async (err: Error, result: boolean) => {
      if (!result) {
        return res.status(400).json({ error: 'Old password is incorrect' }).end();
      }

      bycrypt.hash(new_password, SALT_ROUNDS, async (err: Error, hash: string) => {
        if (err) {
          console.log(err);
          return res.sendStatus(400);
        }

        user.authentication.password = hash;

        // Remove all tokens
        user.authentication.tokens = [];

        await user.save();

        return res.status(200).json(user).end();
      });
    });
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const getUserCategories = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    return res.status(200).json(user.default_categories).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const addUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId } = req.params;
    const { category } = req.body;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const categoryExist = user.books.some((categoryObject: { name: string }) => categoryObject.name === category);
    if (categoryExist) {
      return res.status(400).json({ error: 'Category already exists' }).end();
    }

    user.default_categories.push({ name: category });

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, categoryId } = req.params;
    const { new_category } = req.body;

    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }
    
    const categoryIndex = user.default_categories.findIndex((categoryObject: { _id: ObjectId }) => categoryObject._id.toString() === categoryId);

    if (categoryIndex === -1) {
      return res.status(400).json({ error: 'Category does not exist' }).end();
    }

    user.default_categories[categoryIndex].name = new_category;

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const deleteUserCategory = async (req: express.Request, res: express.Response) => {
  try {
    const { userId, categoryId } = req.params;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User does not exist' }).end();
    }

    const categoryIndex = user.default_categories.findIndex((categoryObject: { _id: ObjectId }) => categoryObject._id.toString() === categoryId);

    if (categoryIndex === -1) {
      return res.status(400).json({ error: 'Category does not exist' }).end();
    }

    user.default_categories.splice(categoryIndex, 1);

    await user.save();

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}