--
-- EXTENSIONS
--
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- SCHEMA
--
CREATE schema api;

-- LOCATIONS Table  Definition
CREATE table api.locations (
  id         serial    PRIMARY KEY,
  _uuid      uuid      DEFAULT uuid_generate_v4(),  -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,   -- added automatically on creation
  updated_on timestamp DEFAULT null,                -- see set_updated_on_column()

  city       varchar(256) DEFAULT null,
  state      varchar(2)   DEFAULT null,
  county     varchar(128) DEFAULT null,
  zipcode    varchar(12)  DEFAULT null,

  latitude   decimal      DEFAULT null,
  longitude  decimal      DEFAULT null,
  geojson    json         DEFAULT null
);

-- DETAILS Table  Definition
CREATE table api.details (
  -- internals
  id         serial    PRIMARY KEY,
  _uuid      uuid      DEFAULT uuid_generate_v4(),  -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,   -- added automatically on creation
  updated_on timestamp DEFAULT null,                -- see set_updated_on_column()

  description text     NOT NULL
);

-- RAID TYPES Table  Definition
CREATE table api.raid_types (
  -- internals
  id         serial    PRIMARY KEY,
  _uuid      uuid      DEFAULT uuid_generate_v4(),  -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,   -- added automatically on creation
  updated_on timestamp DEFAULT null,                -- see set_updated_on_column()

  name        text     NOT null,
  description text     NOT null
);

-- RAIDS Table Definition
CREATE table api.raids (
  -- internals
  id         serial    PRIMARY KEY,
  _uuid      uuid      DEFAULT uuid_generate_v4(),  -- automatically add uuid4
  created_on timestamp DEFAULT current_timestamp,   -- added automatically on creation
  updated_on timestamp DEFAULT null,                -- see set_updated_on_column()

  --
  -- internal organizational fields
  --
  story                      varchar(32) NOT null,
  reference                  varchar(32) NOT null,
  report_citation_reference  varchar(32) NOT null,
  approved_on                timestamp   DEFAULT null,
  approved_by                numeric     DEFAULT null,

  --
  -- information about the raid itself
  --
  _type      smallint  DEFAULT null,            -- points to raid_types table
  datetime   timestamp DEFAULT null,            -- time of raid
  summary    text      DEFAULT null,            -- narrative summary
  exact_date boolean   NOT NULL DEFAULT true,   -- default to true. if false and datetime exists,
                                                --   datetime is an approximation

  -- information about the target
  status              varchar(16) DEFAULT null,
  years_in_us         smallint    DEFAULT null,
  non_targets_present smallint    DEFAULT null

  -- location: points to a location (fk-related)
  -- location_id smallint REFERENCES api.locations (location_id)

  -- details: array of detail.id's
  -- raid_details_id smallint REFERENCES raid_details (raid_id)
);

create table api.raid_details (
  -- internals
  id         serial    PRIMARY KEY,

  -- actual table stuffs
  raid_id   smallint REFERENCES raids (raid_id),
  detail_id smallint REFERENCES details (detail_id)
);

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

-- Create Trigger to fire off the function that updtes the updated_on field after a row is updated
CREATE TRIGGER update_locations_set_updated_on BEFORE UPDATE
ON locations FOR EACH ROW EXECUTE PROCEDURE
set_updated_on_column();

CREATE TRIGGER update_details_set_updated_on BEFORE UPDATE
ON details FOR EACH ROW EXECUTE PROCEDURE
set_updated_on_column();

CREATE TRIGGER update_raids_set_updated_on BEFORE UPDATE
ON api.raids FOR EACH ROW EXECUTE PROCEDURE
set_updated_on_column();

--
-- ROLES
--
create role anon nologin;
grant anon to postgres;

grant usage on schema api to anon;
grant select on api.locations to anon;
grant select on api.details to anon;
grant select on api.raids to anon;
