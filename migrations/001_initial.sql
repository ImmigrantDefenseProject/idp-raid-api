CREATE schema api;

-- Install the uuid-ossp extension so we can autogenerate UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- Define some tables
CREATE table api.locations (
  id         serial    PRIMARY KEY,
  _uuid      uuid      NOT NULL DEFAULT uuid_generate_v4(),    -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,              -- added automatically on creation
  updated_on timestamp DEFAULT null,                           -- see update_updated_on_colum()

  city
  state
  county
  zipcode

  latitude
  longitude

  resolution
)


CREATE table api.details (
  -- internals
  id         serial    PRIMARY KEY,
  _uuid      uuid      NOT NULL DEFAULT uuid_generate_v4(),    -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,              -- added automatically on creation
  updated_on timestamp DEFAULT null,                           -- see update_updated_on_colum()

  description text not null,
)


-- RAIDS Table Definition
CREATE table api.raids (
  -- internals
  id         serial        PRIMARY KEY,
  _uuid       uuid       NOT NULL DEFAULT uuid_generate_v4(),    -- n.b. automatically add uuid4
  created_on
  updated_on

  --
  -- internal organizational fields
  --
  story
  reference
  report_citation_reference
  approved_on


  --
  -- information about the raid itself
  --

  _type
  datetime
  exact_date   -- default to true. if is false and datetiem exists, datetime is an approximation
  summary

  -- information about the target
  status
  years_in_us
  non_targets_present

  -- location: points to a location (fk-related)
  location_id

  -- details: array of detail.id's
  details
)

--
-- UPDATED ON
--

-- we define a function to set updated_on on when a table is updated
-- we then add it to every table with an updated_on column

CREATE OR  REPLACE FUNCTION set_updated_on_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_on = now();
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

-- Create Trigger to fire off the function that updtes the updated_on field after a row is updated
CREATE TRIGGER update_locations_changetimestamp BEFORE UPDATE
ON locations FOR EACH ROW EXECUTE PROCEDURE
update_changetimestamp_column();

CREATE TRIGGER update_details_changetimestamp BEFORE UPDATE
ON details FOR EACH ROW EXECUTE PROCEDURE
update_changetimestamp_column();

CREATE TRIGGER update_raids_changetimestamp BEFORE UPDATE
ON raids FOR EACH ROW EXECUTE PROCEDURE
update_changetimestamp_column();
