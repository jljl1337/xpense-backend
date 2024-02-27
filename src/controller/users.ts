import express from 'express';
import bycrypt from 'bcrypt';

import { getUserByEmail } from '../db/users';
import { meetPasswordRequirements } from '../helper';

const SALT_ROUNDS = Number(process.env.SALT_ROUNDS);

export const getUser = async (req: express.Request, res: express.Response) => {
  try {
    const { email } = req.params;
    const user = await getUserByEmail(email);

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    return res.status(200).json(user).end();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const updateUserInfo = async (req: express.Request, res: express.Response) => {
  try {
    const { email } = req.params;
    const user = await getUserByEmail(email);

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const { new_username, new_email } = req.body;

    if (!new_username && !new_email) {
      return res.status(400).json({ error: 'New username or email is required' }).end();
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
    const { email } = req.params;
    const user = await getUserByEmail(email).select('+authentication.password +authentication.tokens');

    if (!user) {
      return res.status(404).json({ error: 'User with this email does not exist' }).end();
    }

    const { old_password, new_password } = req.body;

    if (!old_password || !new_password) {
      return res.status(400).json({ error: 'Old and new password are required' }).end();
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