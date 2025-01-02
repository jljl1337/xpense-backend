SET search_path TO xpense;

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
    INSERT INTO xpense.payment_method (user_id, book_id, name, description)
    VALUES (
        CASE WHEN book_id IS NULL THEN auth.uid() ELSE NULL END,
        book_id,
        name,
        description
    );
END;
$$;

-- Get payment method function
CREATE OR REPLACE FUNCTION get_payment_methods(
    book_id uuid DEFAULT NULL
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
        xpense.payment_method AS pm
    WHERE
        CASE
            WHEN get_payment_methods.book_id IS NULL THEN pm.user_id = auth.uid()
            ELSE pm.book_id = get_payment_methods.book_id
        END AND
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
    UPDATE
        xpense.payment_method AS pm
    SET
        name = update_payment_method.name,
        description = update_payment_method.description
    WHERE
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
    -- Delete payment method by deactivating it
    UPDATE
        xpense.payment_method AS pm
    SET
        is_active = FALSE
    WHERE
        pm.id = delete_payment_method.id;
END;
$$;