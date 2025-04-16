-- Create expense function
CREATE OR REPLACE FUNCTION xpense.create_expense(
    book_id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    remark text,
    date timestamptz
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO expense (book_id, category_id, payment_method_id, amount, remark, date)
    VALUES (book_id, category_id, payment_method_id, amount, remark, date);
END;
$$;

-- Get expense function
CREATE OR REPLACE FUNCTION xpense.get_expenses(
    id uuid DEFAULT NULL,
    book_id uuid DEFAULT NULL,
    page integer DEFAULT 1,
    page_size integer DEFAULT 25
)
RETURNS SETOF xpense_private.expense
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- parameter validation
    IF page < 1 THEN
        RAISE EXCEPTION 'Invalid page number';
    END IF;

    IF page_size < 1 OR page_size > 100 THEN
        RAISE EXCEPTION 'Invalid page size';
    END IF;

    IF id IS NOT NULL AND page > 1 THEN
        RAISE EXCEPTION 'Page number must be 1 when id is provided';
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

-- Update expense function
CREATE OR REPLACE FUNCTION xpense.update_expense(
    id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    remark text,
    date timestamptz
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    UPDATE
        expense AS e
    SET
        category_id = update_expense.category_id,
        payment_method_id = update_expense.payment_method_id,
        amount = update_expense.amount,
        remark = update_expense.remark,
        date = update_expense.date
    WHERE
        e.id = update_expense.id AND
        e.is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Expense does not exist';
    END IF;
END;
$$;

-- Delete expense function
CREATE OR REPLACE FUNCTION xpense.delete_expense(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    -- Delete expense by deactivating it
    UPDATE
        expense AS e
    SET
        is_active = FALSE
    WHERE
        e.id = delete_expense.id AND
        e.is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Expense does not exist';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION xpense.get_expenses_count(
    book_id uuid
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
            e.is_active = TRUE
    );
END;
$$;