#!/bin/bash

# Check if the flag file exists
if [ ! -f tmp/.db_initialized ]; then
  # If the flag file does not exist, run the setup tasks
  bundle exec rails db:setup
  # Create the flag file to indicate that the database has been initialized
  touch tmp/.db_initialized
fi

# Remove any existing server.pid file
rm -f tmp/pids/server.pid

# Start the Rails server
bundle exec rails server -b 0.0.0.0
