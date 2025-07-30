import Config
config :ayo, token_signing_secret: "pRNP0WvnAJhbbjra/5hTdHvIrWUDwoqa"
config :bcrypt_elixir, log_rounds: 1
config :ash, policies: [show_policy_breakdowns?: true]


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ayo, AyoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "SkuiPFX0jEnpXeIeTKheJGi+Jdq2kma76GNRDzc+0CaMsYV5C8deAwUpFFLCyQXS",
  server: false

# In test we don't send emails
config :ayo, Ayo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

  import_config "test_secret.exs"