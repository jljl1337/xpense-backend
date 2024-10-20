-- Create expense function
CREATE OR REPLACE FUNCTION create_expense(
    book_id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    remark text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO public.expense (user_id, book_id, category_id, payment_method_id, amount, remark, date)
    VALUES (auth.uid(), book_id, category_id, payment_method_id, amount, remark, date);
END;
$$;

-- Get expense function
CREATE OR REPLACE FUNCTION get_expenses(
    book_id uuid
)
RETURNS SETOF expense
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.expense AS e
    WHERE
        e.user_id = auth.uid() AND
        e.book_id = get_expenses.book_id AND
        e.is_active = TRUE;
END;
$$;

-- Update expense function
CREATE OR REPLACE FUNCTION update_expense(
    id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    remark text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE
        public.expense AS e
    SET
        category_id = update_expense.category_id,
        payment_method_id = update_expense.payment_method_id,
        amount = update_expense.amount,
        remark = update_expense.remark,
        date = update_expense.date,
        updated_at = NOW()
    WHERE
        e.user_id = auth.uid() AND
        e.id = update_expense.id;
END;
$$;

-- Delete expense function
CREATE OR REPLACE FUNCTION delete_expense(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Delete expense by deactivating it
    UPDATE
        public.expense AS e
    SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE
        e.user_id = auth.uid() AND
        e.id = delete_expense.id;
END;
$$;