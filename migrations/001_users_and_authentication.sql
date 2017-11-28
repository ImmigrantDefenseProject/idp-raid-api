--
-- USERS & AUTHENTICATION
--

-- adapted from example in the postgrest docs

-- We put things inside the basic_auth schema to hide
-- them from public view. Certain public procs/views will
-- refer to helpers and tables inside.

-- TODO: configure DB to use app.jwt_secret

CREATE schema IF NOT EXISTS basic_auth;

-- TODO: how to do IF NOT EXISTS so this doesn't raise an error
CREATE type basic_auth.jwt_token AS (
  token text
);

CREATE table IF NOT EXISTS
basic_auth.users (
  first_name text,
  last_name  text,
  email      text primary key check ( email ~* '^.+@.+\..+$' ),
  pass       text not null check (length(pass) < 512),
  role       name not null check (length(role) < 512)
);

CREATE OR REPLACE function
basic_auth.check_role_exists() returns trigger
  language plpgsql
  as $$
BEGIN
  IF NOT EXISTS (select 1 from pg_roles as r where r.rolname = new.role) THEN
    RAISE foreign_key_violation USING message =
      'unknown database role: ' || new.role;
    RETURN NULL;
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS ensure_user_role_exists ON basic_auth.users;
CREATE CONSTRAINT TRIGGER ensure_user_role_exists
  AFTER INSERT OR UPDATE ON basic_auth.users
  for each row
  EXECUTE procedure basic_auth.check_role_exists();

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE function
basic_auth.encrypt_pass() returns trigger
  language plpgsql
  as $$
BEGIN
  IF tg_op = 'INSERT' OR new.pass <> old.pass THEN
    new.pass = crypt(new.pass, gen_salt('bf'));
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS encrypt_pass on basic_auth.users;
CREATE TRIGGER encrypt_pass
  BEFORE INSERT OR UPDATE ON basic_auth.users
  FOR EACH ROW
  EXECUTE procedure basic_auth.encrypt_pass();

CREATE OR REPLACE FUNCTION
basic_auth.user_role(email text, pass text) RETURNS name
  language plpgsql
  as $$
BEGIN
  RETURN (
  SELECT ROLE FROM basic_auth.users
   WHERE users.email = user_role.email
     AND users.pass = crypt(user_role.pass, users.pass)
  );
END;
$$;

CREATE OR REPLACE FUNCTION
login(email text, pass text) RETURNS basic_auth.jwt_token
  language plpgsql
  as $$
DECLARE
  _role name;
  result basic_auth.jwt_token;
BEGIN
  -- check email and password
  SELECT basic_auth.user_role(email, pass) INTO _role;
  IF _role IS NULL THEN
    RAISE invalid_password USING MESSAGE = 'invalid user or password';
  END IF;

  SELECT sign(
      row_to_json(r), app.jwt_secret
    ) as token
    FROM (
      SELECT _role AS role, login.email AS email,
         extract(epoch from now())::integer + 60 * 60 as exp
    ) r
    INTO result;
  RETURN result;
END;
$$;
