SET search_path TO xpense;

-- Create payment_method function
CREATE OR REPLACE FUNCTION create_payment_method(
    book_id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO xpense.payment_method (book_id, name, description)
    VALUES (book_id, name, description);
END;
$$;

-- Get payment_method function
CREATE OR REPLACE FUNCTION get_payment_methods(
    book_id uuid
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
        pm.book_id = get_payment_methods.book_id AND
        pm.is_active = TRUE;
END;
$$;

-- Update payment_method function
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

-- Delete payment_method function
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
    -- Delete payment_method by deactivating it
    UPDATE
        xpense.payment_method AS pm
    SET
        is_active = FALSE
    WHERE
        pm.id = delete_payment_method.id;
END;
$$;