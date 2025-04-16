CREATE OR REPLACE FUNCTION xpense_private.check_category_same_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM category AS c
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

CREATE OR REPLACE FUNCTION xpense_private.check_payment_method_same_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO 'xpense_private'
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM payment_method AS pm
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