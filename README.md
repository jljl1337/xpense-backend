# xpense-backend

## Setup

1. Install Docker and Node.js
2. Run `npm install` to install supabase cli
3. Run `sudo ln -s /run/user/1000/docker.sock /var/run/docker.sock` if rootless docker is used (and/or update `DOCKER_HOST` to `unix:///run/user/1000/docker.sock`)

## Commands

`npx supabase start` - Start the local Supabase instance
`npx supabase migration new <migration_name>` - Create a new migration
`npx supabase db reset` - Reset and apply all migrations
`npx supabase db dump --data-only -f supabase/seed.sql --local` - Dump the data from the local Supabase instance
