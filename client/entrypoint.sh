#!/bin/bash
set -e

# Change to the app directory
cd /app

# Wait for the Phoenix backend to become available
until curl -s $API_URL/clocks > /dev/null; do
  echo "Waiting for Phoenix backend..."
  sleep 2
done

echo "Phoenix backend is available"

# Start the Nuxt server
npm run dev