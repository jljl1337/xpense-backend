CREATE OR REPLACE FUNCTION xpense.create_category(
    book_id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO category (book_id, name, description)
    VALUES (book_id, name, description);
END;
$$;

CREATE OR REPLACE FUNCTION xpense.get_categories(
    id uuid DEFAULT NULL,
    book_id uuid DEFAULT NULL
)
RETURNS SETOF xpense_private.category
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
        category AS c
    WHERE
        (get_categories.id IS NULL OR c.id = get_categories.id) AND
        (get_categories.book_id IS NULL OR c.book_id = get_categories.book_id) AND
        c.is_active = TRUE
    ORDER BY
        c.name;

    IF NOT FOUND AND get_categories.id IS NOT NULL THEN
        RAISE EXCEPTION 'Category does not exist';
    END IF;
    RETURN;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.update_category(
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
        category AS c
    SET
        name = update_category.name,
        description = update_category.description
    WHERE
        c.id = update_category.id AND
        c.is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Category does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.delete_category(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Delete category by deactivating it
    UPDATE
        category AS c
    SET
        is_active = FALSE
    WHERE
        c.id = delete_category.id AND
        c.is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Category does not exist';
    END IF;
END;
$$;