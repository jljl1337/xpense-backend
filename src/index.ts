import express from 'express';
import https from 'https';
import fs from 'fs';
import bodyParser from 'body-parser';
import cookieParser from 'cookie-parser';
import compression from 'compression';
import cors from 'cors';

import mongoose from 'mongoose';
import router from './router';

const PORT = Number(process.env.PORT);
const KEY_PATH = process.env.KEY_PATH;
const CERT_PATH = process.env.CERT_PATH;
const SERVICE_NAME = process.env.SERVICE_NAME;
const VERSION = process.env.VERSION;

const app = express();

app.use(cors({credentials: true}));
app.use(compression());
app.use(cookieParser());
app.use(bodyParser.json());

const privateKey = fs.readFileSync(KEY_PATH, 'utf8');
const certificate = fs.readFileSync(CERT_PATH, 'utf8');

// Create an HTTPS service with the certificate and private key.
const server = https.createServer({ key: privateKey, cert: certificate }, app);

server.listen(PORT, () => {
  console.log(`Server is running on port: ${PORT}`);
});

const MONGODB_URL = process.env.MONGODB_URL

mongoose.connect(MONGODB_URL)
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((error) => {
    console.log('MongoDB Error: ', error);
  });

mongoose.set('toJSON', {
  virtuals: true,
  transform: (doc, converted) => {
    delete converted._id;
  }
});

server.on('error', (error: any) => {
  console.log('Error: ', error);
});

app.use(`/${SERVICE_NAME}/v${VERSION}`, router());