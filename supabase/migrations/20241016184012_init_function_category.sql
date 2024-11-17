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
    VALUES (
        CASE WHEN book_id IS NULL THEN auth.uid() ELSE NULL END,
        book_id,
        name,
        description
    );
END;
$$;

-- Get category function
CREATE OR REPLACE FUNCTION get_categories(
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
        CASE
            WHEN get_categories.book_id IS NULL THEN c.user_id = auth.uid()
            ELSE c.book_id = get_categories.book_id
        END AND
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
        public.category AS c
    SET
        is_active = FALSE
    WHERE
        c.id = delete_category.id;
END;
$$;