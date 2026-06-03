defmodule Ecohabits.Repo do
  use Ecto.Repo,
    otp_app: :ecohabits,
    adapter: Ecto.Adapters.Postgres
end
