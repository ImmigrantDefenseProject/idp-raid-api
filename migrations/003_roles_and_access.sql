--
-- ROLES
--

-- anonymous user
CREATE role anon nologin;

-- authenticator role
CREATE role authenticator noinherit;
GRANT anon to authenticator;

-- grant access to authentication
GRANT usage on schema public, basic_auth to anon;
GRANT select on table pg_authid, basic_auth.users to anon;
GRANT EXECUTE on function login(text, text) to anon;

-- grant access to tables
GRANT usage on schema api to anon;
GRANT select on api.locations to anon;
GRANT select on api.details to anon;
GRANT select on api.raids to anon;
GRANT select on api.raid_types to anon;
GRANT usage on schema basic_auth to anon;

-- idp user: can read and write
CREATE role idp_user;
GRANT usage on schema api to idp_user;
GRANT select, insert on api.locations to idp_user;
GRANT select, insert on api.details to idp_user;
GRANT select, insert on api.raids to idp_user;
GRANT select, insert on api.raid_types to idp_user;
