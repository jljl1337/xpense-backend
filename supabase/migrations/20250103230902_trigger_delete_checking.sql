SET search_path TO xpense;

-- Check if any expense is using this category
CREATE OR REPLACE FUNCTION check_expense_using_category()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Continue only if category is being deleted
    IF NEW.is_active OR NOT OLD.is_active THEN
        RETURN NEW;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM xpense.expense AS e
        WHERE
            e.category_id = NEW.id AND
            e.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Cannot delete category because it is being used by at least one expense';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_expense_using_category
BEFORE UPDATE ON xpense.category
FOR EACH ROW
EXECUTE FUNCTION check_expense_using_category();

-- Check if any expense is using this payment method
CREATE OR REPLACE FUNCTION check_expense_using_payment_method()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Continue only if payment method is being deleted
    IF NEW.is_active OR NOT OLD.is_active THEN
        RETURN NEW;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM xpense.expense AS e
        WHERE
            e.payment_method_id = NEW.id AND
            e.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Cannot delete payment method because it is being used by at least one expense';
    END IF;

    RETURN NEW;
END;
$$;

