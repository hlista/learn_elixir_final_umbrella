FROM elixir:1.17-alpine AS builder
# Install necessary packages
RUN apk add --no-cache build-base git npm curl

# Set working directory
WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV="prod"

RUN mkdir apps
COPY /apps ./apps
# Cache deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy app source and compile
COPY . .
RUN mix compile

COPY config/runtime.exs config/

# For Phoenix: build static assets
# RUN npm install --prefix assets && npm run deploy --prefix assets && mix phx.digest

# Build release
RUN MIX_ENV=prod mix release learn_elixir_final

FROM elixir:1.17-alpine AS app

RUN apk add --no-cache openssl ncurses-libs libstdc++

ENV MIX_ENV=prod LANG=C.UTF-8 REPLACE_OS_VARS=true

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/learn_elixir_final ./
RUN chmod +x bin/learn_elixir_final
COPY --from=builder /app/apps/learn_elixir_final/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]


# FROM elixir:latest

# WORKDIR /app
# COPY . .
# RUN apt-get update && \
#     apt-get install -y postgresql-client
# RUN mix local.hex --force && mix local.rebar --force
# # RUN mix deps.get && mix compile

# RUN MIX_ENV=prod mix release learn_elixir_final --overwrite

# ENV RELEASE_NODE="learn_elixir_final@$(hostname -i)"

# CMD ["./apps/learn_elixir_final/entrypoint.sh"]
# CMD ["elixir", "--sname", "$NODE_NAME@$NODE_NAME", "--cookie", "$ELIXIR_COOKIE", "-S", "mix", "run", "--no-halt"]
