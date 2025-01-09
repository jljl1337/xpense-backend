SET search_path TO xpense;

CREATE TABLE payment_method_history (
    id uuid NOT NULL,
    book_id uuid NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    is_active boolean NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    history_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    history_user_id uuid NOT NULL DEFAULT auth.uid()
);

ALTER TABLE payment_method_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User can view their payment_method_history"
ON payment_method_history FOR SELECT
TO authenticated
USING ( can_access_book(book_id) );

CREATE OR REPLACE FUNCTION process_payment_method_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
    INSERT INTO xpense.payment_method_history (
        id, book_id, created_at, updated_at, is_active, name, description
    )
    VALUES (
        NEW.id, NEW.book_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.name, NEW.description
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER payment_method_history_trigger
AFTER INSERT OR UPDATE ON xpense.payment_method
FOR EACH ROW
EXECUTE FUNCTION process_payment_method_history();
