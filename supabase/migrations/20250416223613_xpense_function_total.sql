CREATE OR REPLACE FUNCTION xpense.get_total(
    book_id uuid,
    days integer DEFAULT NULL
)
RETURNS numeric
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
DECLARE
    date_min timestamptz;
    total_amount numeric;
BEGIN
    IF days < 1 THEN
        RAISE EXCEPTION 'days must be greater than 0';
    END IF;

    -- Check if the book exists
    PERFORM xpense.get_books(book_id);

    -- Check if there are any expenses for the book
    IF xpense.get_expenses_count(book_id) = 0 THEN
        RAISE EXCEPTION 'No expenses found for the book';
    END IF;

    IF days IS NOT NULL THEN
        SELECT
            MAX(e.date) - INTERVAL '1 day' * (days - 1) AS date
        INTO
            date_min
        FROM
            xpense_private.expense AS e
        WHERE
            e.book_id = get_total.book_id AND
            e.is_active = TRUE;
    END IF;

    -- Calculate the total amount
    SELECT
        SUM(e.amount) AS total_amount
    INTO
        total_amount
    FROM
        xpense_private.expense AS e
    WHERE
        e.book_id = get_total.book_id AND
        e.is_active = TRUE AND
        (days IS NULL OR e.date >= date_min);

    RETURN total_amount;
END;
$$;
