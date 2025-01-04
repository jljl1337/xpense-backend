SET search_path TO xpense;

CREATE OR REPLACE FUNCTION can_access_book(
    book_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN EXISTS (
        SELECT
            1
        FROM
            xpense.book AS b
        WHERE
            b.id = can_access_book.book_id AND
            b.user_id = ( SELECT auth.uid() )
    ); 
END;
$$;