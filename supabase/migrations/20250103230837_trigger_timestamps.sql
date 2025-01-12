SET search_path TO xpense;

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
BEFORE INSERT ON xpense.book
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER category_insert_timestamps
BEFORE INSERT ON xpense.category
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER payment_method_insert_timestamps
BEFORE INSERT ON xpense.payment_method
FOR EACH ROW
EXECUTE FUNCTION handle_insert_timestamps();

CREATE TRIGGER expense_insert_timestamps
BEFORE INSERT ON xpense.expense
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
BEFORE UPDATE ON xpense.book
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER category_update_timestamps
BEFORE UPDATE ON xpense.category
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER payment_method_update_timestamps
BEFORE UPDATE ON xpense.payment_method
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();

CREATE TRIGGER expense_update_timestamps
BEFORE UPDATE ON xpense.expense
FOR EACH ROW
EXECUTE FUNCTION handle_update_timestamps();
