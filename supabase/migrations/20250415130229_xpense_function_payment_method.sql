CREATE OR REPLACE FUNCTION xpense.create_payment_method(
    book_id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO payment_method (book_id, name, description)
    VALUES (book_id, name, description);
END;
$$;

CREATE OR REPLACE FUNCTION xpense.get_payment_methods(
    id uuid DEFAULT NULL,
    book_id uuid DEFAULT NULL
)
RETURNS SETOF xpense_private.payment_method
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    IF id IS NULL AND book_id IS NULL THEN
        RAISE EXCEPTION 'Either id or book_id must be provided';
    END IF;

    -- Check if the book exists
    PERFORM xpense.get_books(book_id);

    RETURN QUERY
    SELECT
        *
    FROM
        payment_method AS pm
    WHERE
        (get_payment_methods.id IS NULL OR pm.id = get_payment_methods.id) AND
        (get_payment_methods.book_id IS NULL OR pm.book_id = get_payment_methods.book_id) AND
        pm.is_active = TRUE
    ORDER BY
        pm.name;
    
    IF NOT FOUND AND get_payment_methods.id IS NOT NULL THEN
        RAISE EXCEPTION 'Payment method does not exist';
    END IF;
    RETURN;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.update_payment_method(
    id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    UPDATE
        payment_method AS pm
    SET
        name = update_payment_method.name,
        description = update_payment_method.description
    WHERE
        pm.id = update_payment_method.id AND
        pm.is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment method does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.delete_payment_method(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Delete payment_method by deactivating it
    UPDATE
        payment_method AS pm
    SET
        is_active = FALSE
    WHERE
        pm.id = delete_payment_method.id AND
        pm.is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment method does not exist';
    END IF;
END;
$$;
