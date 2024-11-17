-- Create book function
CREATE OR REPLACE FUNCTION create_book(
    name text,
    description text
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Create book
    INSERT INTO public.book (name, description, user_id)
    VALUES (name, description, auth.uid());
END;
$$;

-- Get book function
CREATE OR REPLACE FUNCTION get_books()
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
    UPDATE
        public.book AS b
    SET
        name = update_book.name,
        description = update_book.description
    WHERE
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
    UPDATE
        public.book AS b
    SET
        is_active = FALSE
    WHERE
        b.id = delete_book.id;
END;
$$;
