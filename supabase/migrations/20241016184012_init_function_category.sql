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
    UPDATE
        public.category AS c
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
    INTO
        delete_book_id
    FROM
        public.category AS c
    WHERE
        c.user_id = auth.uid() AND
        c.id = delete_category.id;

    -- Delete category by deactivating it
    UPDATE
        public.category AS c
    SET
        is_active = FALSE
    WHERE
        c.user_id = auth.uid() AND
        c.id = delete_category.id;
END;
$$;