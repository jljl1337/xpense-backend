CREATE OR REPLACE FUNCTION handle_insert_timestamps()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Override both created_at and updated_at with the current timestamp
    NEW.created_at = NOW();
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER book_insert_timestamps
BEFORE INSERT ON public.book
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER category_insert_timestamps
BEFORE INSERT ON public.category
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER payment_method_insert_timestamps
BEFORE INSERT ON public.payment_method
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER expense_insert_timestamps
BEFORE INSERT ON public.expense
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE OR REPLACE FUNCTION handle_update_timestamps()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    NEW.created_at = OLD.created_at;
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER book_update_timestamps
BEFORE UPDATE ON public.book
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER category_update_timestamps
BEFORE UPDATE ON public.category
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER payment_method_update_timestamps
BEFORE UPDATE ON public.payment_method
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER expense_update_timestamps
BEFORE UPDATE ON public.expense
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

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
        FROM public.expense AS e
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
BEFORE UPDATE ON public.category
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
        FROM public.expense AS e
        WHERE
            e.payment_method_id = NEW.id AND
            e.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Cannot delete payment method because it is being used by at least one expense';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_expense_using_payment_method
BEFORE UPDATE ON public.payment_method
FOR EACH ROW
EXECUTE FUNCTION check_expense_using_payment_method();

-- Create book trigger
CREATE OR REPLACE FUNCTION public.book_default_category_payment_method()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Copy default category with null book_id to new book
    INSERT INTO
        public.category (book_id, name, description)
    SELECT
        NEW.id,
        c.name,
        c.description
    FROM
        public.category AS c
    WHERE
        c.user_id = NEW.user_id AND
        c.is_active = TRUE;

    -- Copy default payment method with null book_id to new book
    INSERT INTO
        public.payment_method (book_id, name, description)
    SELECT
        NEW.id,
        pm.name,
        pm.description
    FROM
        public.payment_method AS pm
    WHERE
        pm.user_id = NEW.user_id AND
        pm.is_active = TRUE;

    RETURN NEW;
END;
$$;

CREATE TRIGGER book_default_category_payment_method_trigger
AFTER INSERT ON public.book
FOR EACH ROW
EXECUTE FUNCTION public.book_default_category_payment_method();

-- Expense table triggers
CREATE OR REPLACE FUNCTION check_category_same_book()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.category AS c
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
BEFORE INSERT OR UPDATE ON public.expense
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
        FROM public.payment_method AS pm
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
BEFORE INSERT OR UPDATE ON public.expense
FOR EACH ROW
EXECUTE FUNCTION check_payment_method_same_book();
