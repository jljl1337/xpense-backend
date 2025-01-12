FROM node:22-slim

# Activate pnpm
RUN corepack enable

WORKDIR /app
COPY . /app

# Install dependencies
RUN pnpm install

ENTRYPOINT [ "pnpm supabase db push" ]