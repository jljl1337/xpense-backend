CREATE OR REPLACE FUNCTION xpense_private.process_book_history() 
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO book_history (
        id, user_id, created_at, updated_at, is_active, name, description
    )
    VALUES (
        NEW.id, NEW.user_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.name, NEW.description
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION xpense_private.process_category_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO category_history (
        id, book_id, created_at, updated_at, is_active, name, description
    )
    VALUES (
        NEW.id, NEW.book_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.name, NEW.description
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION xpense_private.process_payment_method_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO payment_method_history (
        id, book_id, created_at, updated_at, is_active, name, description
    )
    VALUES (
        NEW.id, NEW.book_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.name, NEW.description
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION xpense_private.process_expense_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'xpense_private'
AS $$
BEGIN
    INSERT INTO expense_history (
        id, book_id, category_id, payment_method_id, created_at, updated_at, is_active, date, amount, remark
    )
    VALUES (
        NEW.id, NEW.book_id, NEW.category_id, NEW.payment_method_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.date, NEW.amount, NEW.remark
    );
    RETURN NEW;
END;
$$;
