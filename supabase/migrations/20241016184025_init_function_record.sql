-- Create record function
CREATE OR REPLACE FUNCTION create_record(
    book_id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    note text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO public.record (user_id, book_id, category_id, payment_method_id, amount, note, date)
    VALUES (auth.uid(), book_id, category_id, payment_method_id, amount, note, date);
END;
$$;

-- Get record function
CREATE OR REPLACE FUNCTION get_record(
    book_id uuid
)
RETURNS SETOF record
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        public.record AS r
    WHERE
        r.user_id = auth.uid() AND
        r.book_id = get_record.book_id AND
        r.is_active = TRUE;
END;
$$;

-- Update record function
CREATE OR REPLACE FUNCTION update_record(
    id uuid,
    category_id uuid,
    payment_method_id uuid,
    amount numeric,
    note text,
    date date
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    UPDATE
        public.record AS r
    SET
        category_id = category_id,
        payment_method_id = payment_method_id,
        amount = amount,
        note = note,
        date = date
    WHERE
        r.user_id = auth.uid() AND
        r.id = update_record.id;
END;
$$;

-- Delete record function
CREATE OR REPLACE FUNCTION delete_record(
    id uuid
)
RETURNS void
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Delete record by deactivating it
    UPDATE
        public.record AS r
    SET
        is_active = FALSE
    WHERE
        r.user_id = auth.uid() AND
        r.id = delete_record.id;
END;
$$;