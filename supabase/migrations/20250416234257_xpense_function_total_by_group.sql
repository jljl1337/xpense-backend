CREATE OR REPLACE FUNCTION xpense.get_total_by_group(
    book_id uuid,
    days integer DEFAULT NULL,
    group_by text DEFAULT 'category'
)
RETURNS TABLE(
    id uuid,
    name text,
    description text,
    total_amount numeric
)
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
DECLARE
    date_min timestamptz;
BEGIN
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
            e.book_id = get_total_by_group.book_id AND
            e.is_active = TRUE;
    END IF;

    IF group_by = 'category' THEN
        RETURN QUERY
        SELECT
            c.id,
            c.name,
            c.description,
            SUM(e.amount) AS total_amount
        FROM
            xpense_private.category AS c
        LEFT JOIN
            xpense_private.expense AS e ON c.id = e.category_id
        WHERE
            e.book_id = get_total_by_group.book_id AND
            e.is_active = TRUE AND
            (days IS NULL OR e.date >= date_min)
        GROUP BY
            c.id,
            c.name,
            c.description
        ORDER BY
            total_amount DESC;
    ELSIF group_by = 'payment_method' THEN
        RETURN QUERY
        SELECT
            pm.id,
            pm.name,
            pm.description,
            SUM(e.amount) AS total_amount
        FROM
            xpense_private.payment_method AS pm
        LEFT JOIN
            xpense_private.expense AS e ON pm.id = e.payment_method_id
        WHERE
            e.book_id = get_total_by_group.book_id AND
            e.is_active = TRUE AND
            (days IS NULL OR e.date >= date_min)
        GROUP BY
            pm.id,
            pm.name,
            pm.description
        ORDER BY
            total_amount DESC;
    ELSE
        RAISE EXCEPTION 'Invalid group_by value. Use "category" or "payment_method".';
    END IF;
END;
$$;
