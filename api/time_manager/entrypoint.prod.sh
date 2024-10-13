#!/bin/bash
set -e

echo "Entrypoint script is running"

# Generate SECRET_KEY_BASE if not set
if [ -z "$SECRET_KEY_BASE" ]; then
    export SECRET_KEY_BASE=$(mix phx.gen.secret)
    echo "Generated new SECRET_KEY_BASE"
fi

# Wait for Postgres to become available
until pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "Waiting for postgres..."
  sleep 5
done

echo "Postgres is available"

# Run migrations
/app/bin/timemanager eval "TimeManager.Release.migrate"

# Start the Phoenix server
exec /app/bin/timemanager start