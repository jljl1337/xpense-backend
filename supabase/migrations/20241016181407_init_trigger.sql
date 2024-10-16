-- Check if any record is using this category
CREATE OR REPLACE FUNCTION check_record_using_category()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.record AS r
        WHERE
            r.user_id = auth.uid() AND
            r.category_id = NEW.id AND
            r.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Cannot delete category because it is being used by at least one record';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_record_using_category
BEFORE UPDATE ON public.category
FOR EACH ROW
EXECUTE FUNCTION check_record_using_category();

-- Check if any record is using this payment method
CREATE OR REPLACE FUNCTION check_record_using_payment_method()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.record AS r
        WHERE
            r.user_id = auth.uid() AND
            r.payment_method_id = NEW.id AND
            r.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Cannot delete payment method because it is being used by at least one record';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_record_using_payment_method
BEFORE UPDATE ON public.payment_method
FOR EACH ROW
EXECUTE FUNCTION check_record_using_payment_method();

-- Create book trigger
CREATE OR REPLACE FUNCTION public.book_default_category_payment_method()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO ''
AS $$
BEGIN
    -- Copy default category with null book_id to new book
    INSERT INTO
        public.category (user_id, book_id, name, description)
    SELECT
        NEW.user_id,
        NEW.id,
        c.name,
        c.description
    FROM
        public.category AS c
    WHERE
        c.user_id = NEW.user_id AND
        c.book_id IS NULL AND
        c.is_active = TRUE;

    -- Copy default payment method with null book_id to new book
    INSERT INTO
        public.payment_method (user_id, book_id, name, description)
    SELECT
        NEW.user_id,
        NEW.id,
        pm.name,
        pm.description
    FROM
        public.payment_method AS pm
    WHERE
        pm.user_id = NEW.user_id AND
        pm.book_id IS NULL AND
        pm.is_active = TRUE;

    RETURN NEW;
END;
$$;

CREATE TRIGGER book_default_category_payment_method_trigger
AFTER INSERT ON public.book
FOR EACH ROW
EXECUTE FUNCTION public.book_default_category_payment_method();

-- Record table triggers
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
            c.user_id = NEW.user_id AND
            c.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Category does not belong to the same book';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_category_same_book
BEFORE INSERT OR UPDATE ON public.record
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
            pm.user_id = NEW.user_id AND
            pm.is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Payment method does not belong to the same book';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_payment_method_same_book
BEFORE INSERT OR UPDATE ON public.record
FOR EACH ROW
EXECUTE FUNCTION check_payment_method_same_book();
