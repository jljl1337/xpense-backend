CREATE OR REPLACE FUNCTION xpense_private.can_access_book(
    book_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    RETURN EXISTS (
        SELECT
            1
        FROM
            book AS b
        WHERE
            b.id = can_access_book.book_id AND
            b.user_id = ( SELECT auth.uid() )
    ); 
END;
$$;