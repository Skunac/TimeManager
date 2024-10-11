# Use an official Elixir runtime as a parent image.
FROM elixir:latest

RUN apt-get update && \
    apt-get install -y postgresql-client

ENV MIX_ENV=dev

# Create app directory and copy the Elixir projects into it.
WORKDIR /app
COPY . .

# Install Hex package manager and Phoenix framework.
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new --force

# Copy entrypoint script to /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]