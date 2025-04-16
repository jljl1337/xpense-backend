#!/bin/bash
set -e

pnpm supabase migration fetch --db-url $DB_URL
pnpm supabase migration up --include-all --db-url $DB_URL