CREATE SCHEMA IF NOT EXISTS xpense;
GRANT USAGE ON SCHEMA xpense TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA xpense GRANT ALL ON TABLES TO authenticated;

SET search_path TO xpense;

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
    user_id uuid REFERENCES auth.users(id),
    book_id uuid REFERENCES book(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL,

    CONSTRAINT category_owner_check CHECK ( (user_id IS NULL) != (book_id IS NULL) )
);

COMMENT ON CONSTRAINT category_owner_check ON category IS 'Category either belongs to a user or a book';

ALTER TABLE category ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their categories"
ON category FOR SELECT
TO authenticated
USING (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);

CREATE POLICY "User can insert their categories"
ON category FOR INSERT
TO authenticated
WITH CHECK (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);

CREATE POLICY "User can update their categories"
ON category FOR UPDATE
TO authenticated
USING (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
)
WITH CHECK (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);

-- Payment method table
CREATE TABLE payment_method (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),
    book_id uuid REFERENCES book(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    name text NOT NULL,
    description text NOT NULL

    CONSTRAINT payment_method_owner_check CHECK ( (user_id IS NULL) != (book_id IS NULL) )
);

COMMENT ON CONSTRAINT payment_method_owner_check ON payment_method IS 'Payment method either belongs to a user or a book';

ALTER TABLE payment_method ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their payment_methods"
ON payment_method FOR SELECT
TO authenticated
USING (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);

CREATE POLICY "User can insert their payment_methods"
ON payment_method FOR INSERT
TO authenticated
WITH CHECK (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);   

CREATE POLICY "User can update their payment_methods"
ON payment_method FOR UPDATE
TO authenticated
USING (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
)
WITH CHECK (
    CASE 
        WHEN user_id IS NOT NULL THEN 
            user_id = (SELECT auth.uid())
        ELSE 
            book_id IN (
                SELECT b.id
                FROM book AS b
                WHERE b.user_id = (SELECT auth.uid())
            )
    END
);

-- Expense table
CREATE TABLE expense (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id uuid NOT NULL REFERENCES book(id),
    category_id uuid NOT NULL REFERENCES category(id),
    payment_method_id uuid NOT NULL REFERENCES payment_method(id),
    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    date timestamptz NOT NULL,
    amount numeric NOT NULL,
    remark text NOT NULL
);

ALTER TABLE expense ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their expenses"
ON expense FOR SELECT
TO authenticated
USING (
    book_id IN (
        SELECT b.id
        FROM book AS b
        WHERE b.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY "User can insert their expenses"
ON expense FOR INSERT
TO authenticated
WITH CHECK (
    book_id IN (
        SELECT b.id
        FROM book AS b
        WHERE b.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY "User can update their expenses"
ON expense FOR UPDATE
TO authenticated
USING (
    book_id IN (
        SELECT b.id
        FROM book AS b
        WHERE b.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    book_id IN (
        SELECT b.id
        FROM book AS b
        WHERE b.user_id = (SELECT auth.uid())
    )
);
