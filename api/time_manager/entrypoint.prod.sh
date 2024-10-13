#!/bin/bash
set -e

echo "Entrypoint script is running"

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