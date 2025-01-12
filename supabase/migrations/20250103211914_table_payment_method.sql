SET search_path TO xpense;

CREATE TABLE payment_method (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES book(id),
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE payment_method ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their payment methods"
ON payment_method FOR SELECT
TO authenticated
USING ( can_access_book(book_id) );

CREATE POLICY "User can insert their payment methods"
ON payment_method FOR INSERT
TO authenticated
WITH CHECK ( can_access_book(book_id) );

CREATE POLICY "User can update their payment methods"
ON payment_method FOR UPDATE
TO authenticated
USING ( can_access_book(book_id) )
WITH CHECK ( can_access_book(book_id) );