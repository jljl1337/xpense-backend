SET search_path TO xpense;

-- Create category function
CREATE OR REPLACE FUNCTION create_category(
    book_id uuid,
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO xpense.category (book_id, name, description)
    VALUES (book_id, name, description);
END;
$$;

-- Get category function
CREATE OR REPLACE FUNCTION get_categories(
    book_id uuid
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
        xpense.category AS c
    WHERE
        c.book_id = get_categories.book_id AND
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
    UPDATE
        xpense.category AS c
    SET
        name = update_category.name,
        description = update_category.description
    WHERE
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
    -- Delete category by deactivating it
    UPDATE
        xpense.category AS c
    SET
        is_active = FALSE
    WHERE
        c.id = delete_category.id;
END;
$$;