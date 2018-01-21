--
-- SCHEMA
--
CREATE SCHEMA IF NOT EXISTS api;
CREATE EXTENSION IF NOT EXISTS "pgjwt";


-- JTW TEST FUNCTION
CREATE OR REPLACE FUNCTION api.jwt_test() RETURNS basic_auth.jwt_token
    LANGUAGE sql
    AS $$
  SELECT sign(
    row_to_json(r), current_setting('idp_raids_api.jwt_secret')
  ) AS token
  FROM (
    SELECT
      'my_role'::text as role,
      extract(epoch from now())::integer + 300 AS exp
  ) r;
$$;

-- LOGIN FUNCTION
CREATE OR REPLACE FUNCTION api.login(
  email text,
  password text
) RETURNS basic_auth.jwt_token
  LANGUAGE plpgsql
  AS $$
DECLARE
  _role name;
  result basic_auth.jwt_token;
BEGIN

  -- check email and password
  SELECT basic_auth.user_role(CAST(email AS text), CAST(pass AS text)) INTO _role;
  IF _role IS NULL THEN
    RAISE invalid_password USING MESSAGE = 'invalid email or password';
  END IF;

  -- grab fields for JWT
  -- encrypt and return JWT
  SELECT sign(
      row_to_json(r), current_setting('idp_raids_api.jwt_secret')
    ) as token
    FROM (
      SELECT _role as role, login.email as email,
        extract(epoch from now())::integer + 60*60 as exp
    ) r
    INTO result;

  -- return the result
  RETURN result;

END;
$$;
