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

RUN mix assets.deploy

RUN mix deps.compile

# Copy app source and compile
RUN mix compile

COPY config/runtime.exs config/

# For Phoenix: build static assets
# RUN npm install --prefix assets && npm run deploy --prefix assets && mix phx.digest

# Build release
RUN MIX_ENV=prod mix release learn_elixir_final_web

FROM elixir:1.17-alpine AS app

RUN apk add --no-cache openssl ncurses-libs libstdc++

ENV MIX_ENV=prod LANG=C.UTF-8 REPLACE_OS_VARS=true RELEASE_NODE="learn_elixir_final_web@$(hostname)"

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/learn_elixir_final_web ./
RUN chmod +x bin/learn_elixir_final_web
# COPY --from=builder /app/apps/learn_elixir_final/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
ENV PORT=4000
EXPOSE 4000

ENV PHX_SERVER=true
ENTRYPOINT ["/app/bin/learn_elixir_final_web"]
CMD ["start"]
