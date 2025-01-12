SET search_path TO xpense;

CREATE TABLE category (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES book(id),
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE category ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their categories"
ON category FOR SELECT
TO authenticated
USING ( can_access_book(book_id) );

CREATE POLICY "User can insert their categories"
ON category FOR INSERT
TO authenticated
WITH CHECK ( can_access_book(book_id) );

CREATE POLICY "User can update their categories"
ON category FOR UPDATE
TO authenticated
USING ( can_access_book(book_id) )
WITH CHECK ( can_access_book(book_id) );