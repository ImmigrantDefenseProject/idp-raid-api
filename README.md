# IDP Raids API

An API for editing & publishing information collected on raids through our efforts.

## Developing Locally

### Requirements

You will need a postgres database someplace. We refer to the db with a URI of the following structure:

    postgres://<username>:<password>@<host>/<db_name>

You will need a `dev.env` file at the root of your project. It should contain the following:

    # postgrest config vars
    DB_URI="postgres://<username>:<password>@<host>/<db_name>"    # this is the db uri
    DB_SCHEMA="api"
    DB_ANON_ROLE="anon"

    # variables for use in scripts
    DB_NAME=<db_name>
    JWT_SECRET=<32-64 char secret key>

### Developing with Docker

**Requirements**

* Docker
  * image:postgrest/postgrest

This has only been tested on postgres 9.4.4

**n.b.** pull this image before the flight

### Developing without Docker

If you're not using Docker just grab the postgrest binary and put it at the root of the project. `postgrest` is already in `.gitignore`.

To run locally, simply do `./postgrest postgrest.dev.conf` from the root of the project. You may need to add the entries to your `postgrest.dev.conf` yourself.

### Structure

This is a PostgREST project so there is no imperative code, just a db schema.
The schema is defined in the sql files in the `migrations` directory.

**Migrations**

     Migration | What it does
    -----------------------------------------------------------
           001 | User and Authentication schema, tables, and functions
           002 | Add authentication functions
           003 | DB Schema for Raids and related models
           004 | Defines roles and defines resource access

**Fixtures**

These are pretty self explanatory.
