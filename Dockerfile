FROM node:22-slim

# Activate pnpm
RUN corepack enable

WORKDIR /app

# Install dependencies
COPY package.json pnpm-lock.yaml /app/
RUN pnpm install --frozen-lockfile

# Copy the supabase project
COPY supabase /app/supabase

ENTRYPOINT [ "pnpm", "supabase", "db", "push" ]