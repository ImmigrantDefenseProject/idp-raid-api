from begriffs/postgrest

# we need the psql binary so we can run migrations
RUN apt-get install postgresql-9.4

# Run Migration Script
RUN ./scripts/migrate

# Run the server
# TODO: figure out what flags we need to run in prod
CMD ["./postgrest"]
