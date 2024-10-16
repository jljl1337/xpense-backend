-- Book table
CREATE TABLE book (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE book ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their books"
ON book FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can insert their books"
ON book FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can update their books"
ON book FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Category table
CREATE TABLE category (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    book_id uuid REFERENCES book(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE category ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their categories"
ON category FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can insert their categories"
ON category FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can update their categories"
ON category FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Payment method table
CREATE TABLE payment_method (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    book_id uuid REFERENCES book(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL
);

ALTER TABLE payment_method ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their payment_methods"
ON payment_method FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can insert their payment_methods"
ON payment_method FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );   

CREATE POLICY "User can update their payment_methods"
ON payment_method FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Record table
CREATE TABLE record (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users(id),
    book_id uuid NOT NULL REFERENCES book(id),
    category_id uuid NOT NULL REFERENCES category(id),
    payment_method_id uuid NOT NULL REFERENCES payment_method(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    date date NOT NULL,
    amount numeric NOT NULL,
    remark text NOT NULL
);

ALTER TABLE record ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their records"
ON record FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can insert their records"
ON record FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

CREATE POLICY "User can update their records"
ON record FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );