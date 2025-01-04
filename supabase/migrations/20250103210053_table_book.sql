SET search_path TO xpense;

CREATE TABLE book (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE book ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their books"
ON book FOR SELECT
TO authenticated
USING ( user_id = (SELECT auth.uid()) );

CREATE POLICY "User can insert their books"
ON book FOR INSERT
TO authenticated
WITH CHECK ( user_id = (SELECT auth.uid()) );

CREATE POLICY "User can update their books"
ON book FOR UPDATE
TO authenticated
USING ( user_id = (SELECT auth.uid()) )
WITH CHECK ( user_id = (SELECT auth.uid()) );