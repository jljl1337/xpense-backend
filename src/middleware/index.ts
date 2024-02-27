import express from 'express';

import { getUserByEmail } from '../db/users';

export const isAuthenticated = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const { email }= req.params;
    const token = req.cookies['XPENSE-TOKEN'];

    // Check if token exists
    if (!token) {
      return res.sendStatus(403);
    }

    // Check if user exists
    const user = await getUserByEmail(email).select('+authentication.tokens');
    if (!user) {
      return res.sendStatus(403);
    }

    // Check if token exists in user's tokens
    const tokenExists = user.authentication.tokens.some((t: { token: string }) => t.token === token);
    if (!tokenExists) {
      return res.sendStatus(403);
    }

    return next();
  } catch (error) {
    console.log(error);
    return res.sendStatus(400);
  }
}
