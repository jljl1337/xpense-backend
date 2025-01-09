SET search_path TO xpense;

CREATE TABLE expense_history (
    id uuid NOT NULL,
    book_id uuid NOT NULL,
    category_id uuid NOT NULL,
    payment_method_id uuid NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    is_active boolean NOT NULL,
    date timestamptz NOT NULL,
    amount numeric NOT NULL,
    remark text NOT NULL,
    history_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    history_user_id uuid NOT NULL DEFAULT auth.uid()
);

ALTER TABLE expense_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their expense_history"
ON expense_history FOR SELECT
TO authenticated
USING ( can_access_book(book_id) );

CREATE OR REPLACE FUNCTION process_expense_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO xpense.expense_history (
        id, book_id, category_id, payment_method_id, created_at, updated_at, is_active, date, amount, remark
    )
    VALUES (
        NEW.id, NEW.book_id, NEW.category_id, NEW.payment_method_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.date, NEW.amount, NEW.remark
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER expense_history_trigger
AFTER INSERT OR UPDATE ON xpense.expense
FOR EACH ROW
EXECUTE FUNCTION process_expense_history();
