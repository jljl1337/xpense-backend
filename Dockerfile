FROM node:20

# Create app directory
WORKDIR /usr/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . .

# for typescript
RUN npm run build
# WORKDIR ./dist

# EXPOSE 53888
# CMD node --env-file=.env ./dist/index.js
CMD node ./dist/index.js