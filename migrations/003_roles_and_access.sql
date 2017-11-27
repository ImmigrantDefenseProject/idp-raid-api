--
-- ROLES
--

-- anonymous user: can read
CREATE role anon nologin;
GRANT usage on schema api to anon;
GRANT select on api.locations to anon;
GRANT select on api.details to anon;
GRANT select on api.raids to anon;
GRANT select on api.raid_types to anon;

-- idp user: can read and write
CREATE role idp_user;
GRANT usage on schema api to idp_user;
GRANT select, insert on api.locations to idp_user;
GRANT select, insert on api.details to idp_user;
GRANT select, insert on api.raids to idp_user;
GRANT select, insert on api.raid_types to idp_user;
