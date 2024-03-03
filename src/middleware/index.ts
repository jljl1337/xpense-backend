import express from 'express';

import { getUserById } from '../db/users';

const COOKIE_KEY = process.env.COOKIE_KEY;

export const isAuthenticated = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const { userId }= req.params;
    const token = req.cookies[COOKIE_KEY];

    // Check if token exists
    if (!token) {
      return res.status(401).json({ error: 'Please login again.'});
    }

    // Check if user exists
    const user = await getUserById(userId).select('+authentication.tokens');
    if (!user) {
      return res.status(401).json({ error: 'Please login again.'});
    }

    // Check if token exists in user's tokens, and update lastUsed if it does
    const tokenExists = user.authentication.tokens.some((t: { token: string, lastUsed: Date }) => {
      if (t.token === token) {
        t.lastUsed = new Date();
        user.save();

        return true;
      }
      return false;
    });

    if (!tokenExists) {
      return res.status(401).json({ error: 'Please login again.'});
    }

    return next();
  } catch (error) {
    console.log(error);
    return res.status(400).json({ error: error.message }).end();
  }
}
