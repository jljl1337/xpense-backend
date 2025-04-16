ALTER SCHEMA xpense RENAME TO xpense_private;

CREATE SCHEMA IF NOT EXISTS xpense;
GRANT USAGE ON SCHEMA xpense TO authenticated;