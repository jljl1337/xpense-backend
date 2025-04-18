DROP FUNCTION IF EXISTS xpense.get_expenses;

-- Get expense function
CREATE OR REPLACE FUNCTION xpense.get_expenses(
    id uuid DEFAULT NULL,
    book_id uuid DEFAULT NULL,
    category_id uuid DEFAULT NULL,
    payment_method_id uuid DEFAULT NULL,
    remark text DEFAULT NULL,
    page integer DEFAULT 1,
    page_size integer DEFAULT 25
)
RETURNS SETOF xpense_private.expense
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- parameter validation
    IF id IS NULL AND book_id IS NULL THEN
        RAISE EXCEPTION 'Either id or book_id must be provided';
    END IF;

    IF page < 1 THEN
        RAISE EXCEPTION 'Invalid page number';
    END IF;

    IF page_size < 1 OR page_size > 100 THEN
        RAISE EXCEPTION 'Invalid page size';
    END IF;

    IF id IS NOT NULL AND page > 1 THEN
        RAISE EXCEPTION 'Page number must be 1 when id is provided';
    END IF;

    IF category_id IS NOT NULL THEN
        -- Check if the category exists in the book
        PERFORM xpense.get_categories(category_id, book_id);
    END IF;

    IF payment_method_id IS NOT NULL THEN
        -- Check if the payment method exists in the book
        PERFORM xpense.get_payment_methods(payment_method_id, book_id);
    END IF;

    -- Check if the book exists
    PERFORM xpense.get_books(book_id);

    RETURN QUERY
    SELECT
        *
    FROM
        expense AS e
    WHERE
        (get_expenses.id IS NULL OR e.id = get_expenses.id) AND
        (get_expenses.book_id IS NULL OR e.book_id = get_expenses.book_id) AND
        (get_expenses.category_id IS NULL OR e.category_id = get_expenses.category_id) AND
        (get_expenses.payment_method_id IS NULL OR e.payment_method_id = get_expenses.payment_method_id) AND
        (get_expenses.remark IS NULL OR POSITION(get_expenses.remark IN e.remark) > 0) AND
        e.is_active = TRUE
    ORDER BY
        e.date DESC,
        e.updated_at DESC
    LIMIT
        page_size
    OFFSET
        (page - 1) * page_size;

    IF NOT FOUND AND get_expenses.id IS NOT NULL THEN
        RAISE EXCEPTION 'Expense does not exist';
    END IF;
END;
$$;

DROP FUNCTION IF EXISTS xpense.get_expenses_count;

CREATE OR REPLACE FUNCTION xpense.get_expenses_count(
    book_id uuid,
    category_id uuid DEFAULT NULL,
    payment_method_id uuid DEFAULT NULL,
    remark text DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Check if the book exists
    PERFORM xpense.get_books(book_id);

    RETURN (
        SELECT
            COUNT(*)
        FROM
            expense AS e
        WHERE
            e.book_id = get_expenses_count.book_id AND
            (get_expenses_count.category_id IS NULL OR e.category_id = get_expenses_count.category_id) AND
            (get_expenses_count.payment_method_id IS NULL OR e.payment_method_id = get_expenses_count.payment_method_id) AND
            (get_expenses_count.remark IS NULL OR POSITION(get_expenses_count.remark IN e.remark) > 0) AND
            e.is_active = TRUE
    );
END;
$$;
