-- now we define a function to set updated_on on when a table is updated
-- we then add it to every table with an updated_on column

-- Create a function to update the `updated_on` column
CREATE OR  REPLACE FUNCTION set_updated_on_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.changetimestamp = now();
   RETURN NEW;
END;
$$;

-- Add to relevant tables
DO
$do$
BEGIN
FOR i IN 1..25 LOOP
    CREATE TRIGGER update_{table}_changetimestamp BEFORE UPDATE
    ON ab FOR EACH ROW EXECUTE PROCEDURE
    update_changetimestamp_column();
END;
$$;
