-- Create history table
CREATE TABLE book_history (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    is_active boolean NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    -- Additional history tracking columns
    history_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    history_timestamp timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
    history_user_id uuid DEFAULT auth.uid()
);

-- Enable RLS on history table
ALTER TABLE book_history ENABLE ROW LEVEL SECURITY;

-- Create policy for selecting from history
CREATE POLICY "User can view their book history"
ON book_history FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

-- Create policy for inserting into history (via trigger only)
CREATE POLICY "User can insert their book history"
ON book_history FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Create function for trigger
CREATE OR REPLACE FUNCTION process_book_history() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO book_history (
        id, user_id, created_at, updated_at, is_active, name, description
    )
    VALUES (
        NEW.id, NEW.user_id, NEW.created_at, NEW.updated_at, NEW.is_active, NEW.name, NEW.description
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER book_history_trigger
    AFTER INSERT OR UPDATE ON book
    FOR EACH ROW
    EXECUTE FUNCTION process_book_history();