CREATE OR REPLACE FUNCTION xpense.get_trend(
    book_id uuid,
    days integer
)
RETURNS TABLE(
    date timestamptz,
    total_amount numeric
)
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
DECLARE
    latest_date timestamptz;
BEGIN
    IF days < 1 OR days > 100 THEN
        RAISE EXCEPTION 'days must be between 1 and 100';
    END IF;

    -- Check if the book exists
    PERFORM xpense.get_books(book_id);

    IF xpense.get_expenses_count(book_id) = 0 THEN
        RAISE EXCEPTION 'No expenses found for the book';
    END IF;

    SELECT
        MAX(e.date) AS date
    INTO
        latest_date
    FROM
        xpense_private.expense AS e
    WHERE
        e.book_id = get_trend.book_id AND
        e.is_active = TRUE;

    RETURN QUERY

    WITH date_series AS (
        SELECT
            latest_date - INTERVAL '1 day' * g AS date
        FROM
            generate_series(0, days - 1) AS g
    ),

    date_total AS (
        SELECT
            e.date AS date,
            SUM(e.amount) AS total_amount
        FROM
            xpense_private.expense AS e
        WHERE
            e.book_id = get_trend.book_id AND
            e.date >= latest_date - INTERVAL '1 day' * (days - 1) AND
            e.is_active = TRUE
        GROUP BY
            e.date
    )

    SELECT
        ds.date AS date,
        COALESCE(dt.total_amount, 0) AS total_amount
    FROM
        date_series AS ds
    LEFT JOIN
        date_total AS dt
    ON
        ds.date = dt.date
    ORDER BY
        ds.date;
END;
$$;