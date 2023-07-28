#!/bin/bash

# Check if the flag file exists
if [ ! -f tmp/.db_initialized ]; then
  echo "Flag file not found. Running setup tasks..."
  # Run the setup tasks and set DB_SETUP_SUCCESS to 1 if successful
    if bundle exec rails db:setup; then
      DB_SETUP_SUCCESS=1
      # Create the flag file to indicate that the database has been initialized
      touch tmp/.db_initialized
      echo "Database setup successfully and seeded."
    else
      echo "Database setup tasks failed. Check the logs for details."
    fi
  else
    echo "Flag file found. Skipping setup tasks."
    DB_SETUP_SUCCESS=1
fi

# Remove any existing server.pid file
rm -f tmp/pids/server.pid

# Start the Rails server
bundle exec rails server -b 0.0.0.0
