defmodule Ayo.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Ayo.Accounts.User, _opts, _context) do
    Application.fetch_env(:ayo, :token_signing_secret)
  end
end
