SET search_path TO xpense;

CREATE TRIGGER enforce_expense_using_payment_method
BEFORE UPDATE ON xpense.payment_method
FOR EACH ROW
EXECUTE FUNCTION check_expense_using_payment_method();