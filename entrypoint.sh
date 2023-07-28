#!/bin/bash

FLAG_FILE="/usr/src/app/tmp/.db_initialized"

# Check if the flag file exists
if [ ! -f "$FLAG_FILE" ]; then
  # Run the setup tasks if the flag file doesn't exist
  bundle exec rails db:setup
  bundle exec rails db:migrate
  bundle exec rails db:seed

  # Create the flag file to indicate that the setup tasks have been executed
  touch "$FLAG_FILE"
fi

# Remove any existing server.pid file
rm -f tmp/pids/server.pid

# Start the Rails server
bundle exec rails server -b 0.0.0.0
