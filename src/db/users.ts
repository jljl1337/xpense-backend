import mongoose from 'mongoose';

import { BookSchema, CategorySchema } from './books';

// User Config
const UserSchema = new mongoose.Schema({
  email: { type: String, required: true },
  username: { type: String, required: true },
  authentication: {
    password: { type: String, required: true, select: false },
    tokens: { 
      type: [
        {
          token: { type: String, required: true },
          lastUsed: { type: Date, required: true },
        },
      ],
      select: false,
      required: false,
    },
  },
  default_categories: { type: [CategorySchema], required: true },
  books: { type: [BookSchema], default: [] },
});

export const UserModel = mongoose.model('User', UserSchema);

// User Actions
export const getUsers = () => UserModel.find();
export const getUserByEmail = (email: string) => UserModel.findOne({ email });
// export const getUserBySessionToken = (sessionToken: string) => UserModel.findOne({ 'authentication.sessionToken': sessionToken });
export const addTokenToUser = (id: string, token: string, lastUsed: Date) => UserModel.findByIdAndUpdate(id, { $push: { 'authentication.tokens': { token, lastUsed } } });
export const getUserById = (id: string) => UserModel.findById(id);
export const createUser = (values: Record<string, any>) => new UserModel(values).save().then((user) => user.toObject());
// export const deleteUserById = (id: string) => UserModel.findOneAndDelete({ _id: id });
// export const updateUserById = (id: string, values: Record<string, any>) => UserModel.findByIdAndUpdate(id, values);