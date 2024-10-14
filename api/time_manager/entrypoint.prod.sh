#!/bin/bash
set -e

echo "Entrypoint script is running"

# Path to store the SECRET_KEY_BASE
SECRET_FILE="/app/secret_key_base/secret_key_base"

# Function to generate a random string
generate_secret() {
    openssl rand -base64 48 | tr -d "\n"
}

# Generate SECRET_KEY_BASE if not set and not stored
if [ -z "$SECRET_KEY_BASE" ]; then
    if [ ! -f "$SECRET_FILE" ]; then
        generate_secret > "$SECRET_FILE"
        echo "Generated new SECRET_KEY_BASE and stored it"
    fi
    export SECRET_KEY_BASE=$(cat "$SECRET_FILE")
    echo "Loaded SECRET_KEY_BASE from file"
fi

# Wait for Postgres to become available
until pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "Waiting for postgres..."
  sleep 5
done

echo "Postgres is available"

# Run migrations
/app/bin/timemanager eval "Timemanager.Release.migrate()"

# Start the Phoenix server
exec /app/bin/timemanager start