-- Set all functions to run with authentication
revoke execute on all functions in schema public from public;
revoke execute on all functions in schema public from anon, authenticated;

alter default privileges in schema public revoke execute on functions from public;
alter default privileges in schema public revoke execute on functions from anon, authenticated;

-- ALTER DEFAULT privileges
-- IN SCHEMA public
-- REVOKE EXECUTE ON functions
-- FROM public;

-- ALTER DEFAULT privileges
-- IN SCHEMA public
-- REVOKE EXECUTE ON functions
-- FROM anon, authenticated;

-- Create category function
CREATE OR REPLACE FUNCTION create_category(
    name text,
    description text,
    book_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO public.category (user_id, book_id, name, description)
    VALUES (auth.uid(), book_id, name, description);
END;
$$;

-- Get category function
CREATE OR REPLACE FUNCTION get_category(
    book_id uuid DEFAULT NULL
)
RETURNS SETOF category
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.category AS c
    WHERE
        c.user_id = auth.uid() AND
        COALESCE(c.book_id::text, '') = COALESCE(get_category.book_id::text, '') AND
        c.is_active = TRUE;
END;
$$;

-- Update category function
CREATE OR REPLACE FUNCTION update_category(
    id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE public.category AS c
    SET
        name = name,
        description = description
    WHERE
        c.user_id = auth.uid() AND
        c.id = update_category.id;
END;
$$;

-- Delete category function
CREATE OR REPLACE FUNCTION delete_category(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
DECLARE
    delete_book_id uuid;
BEGIN
    -- Get book_id
    SELECT
        c.book_id
    INTO delete_book_id
    FROM
        public.category AS c
    WHERE
        c.user_id = auth.uid() AND
        c.id = delete_category.id;

    -- Check if this category is the only category in the book or default category
    IF NOT EXISTS (
        SELECT 1
        FROM public.category AS c
        WHERE
            c.user_id = auth.uid() AND
            c.id <> delete_category.id AND
            COALESCE(c.book_id::text, '') = COALESCE(delete_book_id::text, '')
    ) THEN
        IF delete_book_id IS NULL THEN
            RAISE EXCEPTION 'Cannot delete the default category';
        END IF;
        RAISE EXCEPTION 'Cannot delete the only category in the book';
    END IF;

    -- Check if any record is using this category
    IF EXISTS (
        SELECT 1
        FROM public.record AS r
        WHERE
            r.user_id = auth.uid() AND
            r.category_id = delete_category.id
    ) THEN
        RAISE EXCEPTION 'Cannot delete category because it is being used by a record';
    END IF;

    -- Delete category by deactivating it
    UPDATE public.category AS c
    SET
        is_active = FALSE
    WHERE
        c.user_id = auth.uid() AND
        c.id = delete_category.id;
END;
$$;

-- Create payment method function
CREATE OR REPLACE FUNCTION create_payment_method(
    name text,
    description text,
    book_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO public.payment_method (user_id, book_id, name, description)
    VALUES (auth.uid(), book_id, name, description);
END;
$$;

-- Get payment method function
CREATE OR REPLACE FUNCTION get_payment_method(
    id uuid
)
RETURNS SETOF payment_method
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.payment_method AS pm
    WHERE
        pm.user_id = auth.uid() AND
        COALESCE(pm.book_id::text, '') = COALESCE(get_payment_method.book_id::text, '') AND
        pm.is_active = TRUE;
END;
$$;

-- Update payment method function
CREATE OR REPLACE FUNCTION update_payment_method(
    id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE public.payment_method AS pm
    SET
        name = name,
        description = description
    WHERE
        pm.user_id = auth.uid() AND
        pm.id = update_payment_method.id;
END;
$$;

-- Delete payment method function
CREATE OR REPLACE FUNCTION delete_payment_method(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
DECLARE
    delete_book_id uuid;
BEGIN
    -- Get book_id
    SELECT
        pm.book_id
    INTO delete_book_id
    FROM
        public.payment_method AS pm
    WHERE
        pm.user_id = auth.uid() AND
        pm.id = delete_payment_method.id;

    -- Check if this payment method is the only payment method in the book or default payment method
    IF NOT EXISTS (
        SELECT 1
        FROM public.payment_method AS pm
        WHERE
            pm.user_id = auth.uid() AND
            pm.id <> delete_payment_method.id AND
            COALESCE(pm.book_id::text, '') = COALESCE(delete_book_id::text, '')
    ) THEN
        IF delete_book_id IS NULL THEN
            RAISE EXCEPTION 'Cannot delete the default payment method';
        END IF;
        RAISE EXCEPTION 'Cannot delete the only payment method in the book';
    END IF;

    -- Check if any record is using this payment method
    IF EXISTS (
        SELECT 1
        FROM public.record AS r
        WHERE
            r.user_id = auth.uid() AND
            r.payment_method_id = delete_payment_method.id
    ) THEN
        RAISE EXCEPTION 'Cannot delete payment method because it is being used by a record';
    END IF;

    -- Delete payment method by deactivating it
    UPDATE public.payment_method AS pm
    SET
        is_active = FALSE
    WHERE
        pm.user_id = auth.uid() AND
        pm.id = delete_payment_method.id;
END;
$$;

-- Create book function
CREATE OR REPLACE FUNCTION create_book(
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
DECLARE
    new_book_id uuid;
BEGIN
    -- Check if default category exist
    IF NOT EXISTS (
        SELECT 1
        FROM public.category AS c
        WHERE
            c.user_id = auth.uid() AND
            c.book_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Please create a default category first';
    END IF;

    -- Check if default payment method exist
    IF NOT EXISTS (
        SELECT 1
        FROM public.payment_method AS pm
        WHERE
            pm.user_id = auth.uid() AND
            pm.book_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Please create a default payment method first';
    END IF;

    -- Set book_id
    new_book_id := gen_random_uuid();

    -- Create book
    INSERT INTO public.book (id, name, description, user_id)
    VALUES (new_book_id, name, description, auth.uid());

    -- Copy default category with null book_id to new book
    INSERT INTO
        public.category (user_id, book_id, name, description)
    SELECT
        auth.uid(),
        new_book_id,
        c.name,
        c.description
    FROM
        public.category AS c
    WHERE
        c.user_id = auth.uid() AND
        c.book_id IS NULL;

    -- Copy default payment method with null book_id to new book
    INSERT INTO
        public.payment_method (user_id, book_id, name, description)
    SELECT
        auth.uid(),
        new_book_id,
        pm.name,
        pm.description
    FROM
        public.payment_method AS pm
    WHERE
        pm.user_id = auth.uid() AND
        pm.book_id IS NULL;
END;
$$;

-- Get book function
CREATE OR REPLACE FUNCTION get_book()
RETURNS SETOF book
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.book AS b
    WHERE
        b.user_id = auth.uid() AND
        b.is_active = TRUE;
END;
$$;

-- Update book function
CREATE OR REPLACE FUNCTION update_book(
    id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE public.book AS b
    SET
        name = name,
        description = description
    WHERE
        b.user_id = auth.uid() AND
        b.id = update_book.id;
END;
$$;

-- Delete book function
CREATE OR REPLACE FUNCTION delete_book(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Delete book by deactivating it
    UPDATE public.book AS b
    SET
        is_active = FALSE
    WHERE
        b.user_id = auth.uid() AND
        b.id = delete_book.id;
END;
$$;

-- Create record function
CREATE OR REPLACE FUNCTION create_record(
    book_id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    note text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO public.record (user_id, book_id, category_id, payment_method_id, amount, note, date)
    VALUES (auth.uid(), book_id, category_id, payment_method_id, amount, note, date);
END;
$$;

-- Get record function
CREATE OR REPLACE FUNCTION get_record(
    book_id uuid
)
RETURNS SETOF record
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.record AS r
    WHERE
        r.user_id = auth.uid() AND
        r.book_id = get_record.book_id AND
        r.is_active = TRUE;
END;
$$;

-- Update record function
CREATE OR REPLACE FUNCTION update_record(
    id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    note text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE public.record AS r
    SET
        category_id = category_id,
        payment_method_id = payment_method_id,
        amount = amount,
        note = note,
        date = date
    WHERE
        r.user_id = auth.uid() AND
        r.id = update_record.id;
END;
$$;

-- Delete record function
CREATE OR REPLACE FUNCTION delete_record(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Delete record by deactivating it
    UPDATE public.record AS r
    SET
        is_active = FALSE
    WHERE
        r.user_id = auth.uid() AND
        r.id = delete_record.id;
END;
$$;