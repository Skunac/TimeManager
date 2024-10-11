#!/bin/bash
set -e

echo "Entrypoint script is running"

# Change to the app directory
cd /app

# Wait for Postgres to become available
until pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "Waiting for postgres..."
  sleep 5
done

echo "Postgres is available"

# Install dependencies
mix deps.get

# Compile the project.
mix compile

# Setup the database (create, migrate, seed)
mix ecto.setup

# Start the Phoenix server
mix phx.server