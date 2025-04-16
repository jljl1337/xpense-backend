CREATE OR REPLACE FUNCTION xpense.create_book(
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Create book
    INSERT INTO book (name, description, user_id)
    VALUES (name, description, auth.uid());
END;
$$;

CREATE OR REPLACE FUNCTION xpense.get_books(
    id uuid DEFAULT NULL,
    page integer DEFAULT 1,
    page_size integer DEFAULT 25
)
RETURNS SETOF xpense_private.book
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- parameter validation
    IF page < 1 THEN
        RAISE EXCEPTION 'Invalid page number';
    END IF;

    IF page_size < 1 OR page_size > 100 THEN
        RAISE EXCEPTION 'Invalid page size';
    END IF;

    IF id IS NOT NULL AND page > 1 THEN
        RAISE EXCEPTION 'Page number must be 1 when id is provided';
    END IF;

    RETURN QUERY
    SELECT
        *
    FROM
        book AS b
    WHERE
        (get_books.id IS NULL OR b.id = get_books.id) AND
        b.user_id = auth.uid() AND
        b.is_active = TRUE
    ORDER BY
        b.updated_at DESC
    LIMIT
        page_size
    OFFSET
        (page - 1) * page_size;

    IF NOT FOUND AND get_books.id IS NOT NULL THEN
        RAISE EXCEPTION 'Book does not exist';
    END IF;
    RETURN;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.update_book(
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
        book AS b
    SET
        name = update_book.name,
        description = update_book.description
    WHERE
        b.id = update_book.id AND
        b.user_id = auth.uid() AND
        b.is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Book does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.delete_book(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Delete book by deactivating it
    UPDATE
        book AS b
    SET
        is_active = FALSE
    WHERE
        b.id = delete_book.id AND
        b.user_id = auth.uid() AND
        b.is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Book does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.get_books_count()
RETURNS integer
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    RETURN (
        SELECT
            COUNT(b.id)
        FROM
            book AS b
        WHERE
            b.user_id = auth.uid() AND
            b.is_active = TRUE
    );
END;
$$;