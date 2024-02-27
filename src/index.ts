import express from 'express';
import http from 'http';
import bodyParser from 'body-parser';
import cookieParser from 'cookie-parser';
import compression from 'compression';
import cors from 'cors';

import mongoose from 'mongoose';
import router from './router';

const PORT = Number(process.env.PORT);

const app = express();
const server = http.createServer(app);

server.listen(PORT, () => {
  console.log('Server is running on port: %d', PORT);
});

app.use(cors({credentials: true}));
app.use(compression());
app.use(cookieParser());
app.use(bodyParser.json());

const MONGODB_URL = process.env.MONGODB_URL

console.log('MONGODB_URL: ', MONGODB_URL);

mongoose.connect(MONGODB_URL)
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((error) => {
    console.log('MongoDB Error: ', error);
  });

server.on('error', (error: any) => {
  console.log('Error: ', error);
});

app.use('/', router());