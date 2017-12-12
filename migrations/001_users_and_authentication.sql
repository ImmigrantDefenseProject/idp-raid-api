--
-- USERS & AUTHENTICATION
--

-- adapted from example in the postgrest docs
-- link: https://postgrest.com/en/v4.3/auth.html#schema-isolation

-- We put things inside the basic_auth schema to hide
-- them from public view. Certain public procs/views will
-- refer to helpers and tables inside.

CREATE schema IF NOT EXISTS basic_auth;

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
  AS $$
BEGIN
  IF NOT EXISTS (select 1 from pg_roles AS r where r.rolname = new.role) THEN
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
  AS $$
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

CREATE OR REPLACE FUNCTION basic_auth.user_role(
  email text,
  pass text
) RETURNS name
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN (
  SELECT ROLE FROM basic_auth.users
   WHERE users.email = user_role.email
     AND users.pass = crypt(user_role.pass, users.pass)
  );
END;
$$;

CREATE OR REPLACE FUNCTION basic_auth.login(
  email text,
  pass text
) RETURNS jwt_token
  LANGUAGE plpgsql
  AS $$
DECLARE
  _role name;
  result jwt_token;
BEGIN

  -- check email and password
  SELECT basic_auth.user_role(CAST(email AS text), CAST(pass AS text)) INTO _role;
  IF _role IS NULL THEN
    RAISE invalid_password USING MESSAGE = 'invalid user or password';
  END IF;

  -- grab fields for JWT
  -- encrypt and return JWT
  SELECT email as token INTO result;

  -- return the result
  RETURN result;

END;
$$;
