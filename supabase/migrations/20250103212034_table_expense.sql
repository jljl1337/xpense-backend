SET search_path TO xpense;

CREATE TABLE expense (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES book(id),
    category_id uuid NOT NULL REFERENCES category(id),
    payment_method_id uuid NOT NULL REFERENCES payment_method(id),
    created_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamptz NOT NULL DEFAULT timezone('utc'::text, now()),
    is_active boolean NOT NULL DEFAULT TRUE,
    date timestamptz NOT NULL,
    amount numeric NOT NULL,
    remark text NOT NULL
);

ALTER TABLE expense ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their expenses"
ON expense FOR SELECT
TO authenticated
USING ( can_access_book(book_id) );

CREATE POLICY "User can insert their expenses"
ON expense FOR INSERT
TO authenticated
WITH CHECK ( can_access_book(book_id) );

CREATE POLICY "User can update their expenses"
ON expense FOR UPDATE
TO authenticated
USING ( can_access_book(book_id) )
WITH CHECK ( can_access_book(book_id) );