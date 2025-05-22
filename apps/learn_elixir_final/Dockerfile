FROM elixir:1.17.3-otp-27

WORKDIR /app
COPY . .

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get && mix compile

CMD ["elixir", "--sname", "$NODE_NAME", "--cookie", "$ELIXIR_COOKIE", "-S", "mix", "run", "--no-halt"]