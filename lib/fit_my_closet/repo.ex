defmodule FitMyCloset.Repo do
  use Ecto.Repo,
    otp_app: :fit_my_closet,
    adapter: Ecto.Adapters.SQLite3
end
