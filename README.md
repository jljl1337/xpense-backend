# xpense-backend

## Setup

1. Install Docker and pnpm
2. Run `pnpm i` to install supabase cli
3. Run `sudo ln -s /run/user/1000/docker.sock /var/run/docker.sock` if rootless docker is used (and/or update `DOCKER_HOST` to `unix:///run/user/1000/docker.sock`)

## Commands

All of the following commands are available as VS Code tasks.

`pnpm supabase start` - Start the local Supabase instance
`pnpm supabase stop` - Stop the local Supabase instance
`pnpm supabase status` - Check the status of the running local Supabase instance
`pnpm supabase migration new <migration_name>` - Create a new migration
`pnpm supabase db reset` - Reset and apply all migrations
`pnpm supabase db dump --data-only -f supabase/seed.sql --local` - Dump the data from the local Supabase instance
