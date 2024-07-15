defmodule Water.Repo do
  use Ecto.Repo,
    otp_app: :water,
    adapter: Ecto.Adapters.Postgres
end
