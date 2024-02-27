import express from 'express';
import bycrypt from 'bcrypt';
import crypto from 'crypto';

import { getCategories } from '../db/books';
import { createUser, getUserByEmail } from '../db/users';
import { meetPasswordRequirements } from '../helper';

const SALT_ROUNDS = process.env.SALT_ROUNDS;
const MAX_TOKENS = Number(process.env.MAX_TOKENS);

const generateToken = () => {
  return crypto.randomBytes(128).toString('base64');
}

export const login = async (req: express.Request, res: express.Response) => {
  try {
    const { email, password } = req.body;

    // Check if email and password are provided
    if (!email || !password) {
      return res.sendStatus(400);
    }

    const user = await getUserByEmail(email).select('+authentication.password +authentication.tokens');

    // Check if user with email exists
    if (!user) {
      return res.status(400).json({ error: 'User with this email does not exist' }).end();
    }

    bycrypt.compare(password, user.authentication.password as string, async (err: Error, result: boolean) => {
      if (err) {
        return res.sendStatus(400);
      }

      if (!result) {
        return res.status(400).json({ error: 'Password is incorrect' }).end();
      }

      // Generate session token
      const token = generateToken();
      if (user.authentication.tokens.length >= MAX_TOKENS) {
        // Replace oldest token
        user.authentication.tokens.sort((a: any, b: any) => a.lastUsed - b.lastUsed);
        user.authentication.tokens[0] = { token, lastUsed: new Date() };

      } else {
        // Add new token
        user.authentication.tokens.push({ token, lastUsed: new Date() });
      }

      await user.save();

      res.cookie('XPENSE-TOKEN', token, {httpOnly: true});

      return res.status(200).json(user).end();
    });
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

export const register = async (req: express.Request, res: express.Response) => {
  try {
    console.log(req.body);
    const { email, password, username } = req.body;

    // Check if email, password, and username are provided
    if (!email || !password || !username) {
      return res.sendStatus(400);
    }

    const existingUser = await getUserByEmail(email);
    
    // Check if user with same email already exists
    if (existingUser) {
      return res.status(400).json({ error: 'User with this email already exists' }).end();
    }

    if (!meetPasswordRequirements(password)) {
      return res.status(400).json({ error: 'Password does not meet requirements' }).end();
    }

    bycrypt.hash(password, SALT_ROUNDS, async (err: Error, hash: string) => {
      if (err) {
        return res.sendStatus(400);
      }

      const categories = await getCategories();

      const user = await createUser({
        email,
        username,
        authentication: {
          password: hash,
        },
        default_categories: categories,
      });

      return res.status(200).json(user).end();
    });
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}

