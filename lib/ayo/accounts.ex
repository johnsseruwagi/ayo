defmodule Ayo.Accounts do
  use Ash.Domain,
    otp_app: :ayo

  resources do
    resource Ayo.Accounts.Token
    resource Ayo.Accounts.User
  end
end
