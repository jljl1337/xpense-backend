SET search_path TO xpense;

-- Expense table triggers
CREATE OR REPLACE FUNCTION check_category_same_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM xpense.category AS c
        WHERE
            c.id = NEW.category_id AND
            c.book_id = NEW.book_id AND
            c.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Category does not exist in the book';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_category_same_book
BEFORE INSERT OR UPDATE ON xpense.expense
FOR EACH ROW
EXECUTE FUNCTION check_category_same_book();

CREATE OR REPLACE FUNCTION check_payment_method_same_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM xpense.payment_method AS pm
        WHERE
            pm.id = NEW.payment_method_id AND
            pm.book_id = NEW.book_id AND
            pm.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Payment method does not exist in the book';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_payment_method_same_book
BEFORE INSERT OR UPDATE ON xpense.expense
FOR EACH ROW
EXECUTE FUNCTION check_payment_method_same_book();
