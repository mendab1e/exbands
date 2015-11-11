defmodule Exbands.Postgres do
  @username Application.get_env(:exbands, :username)
  @password Application.get_env(:exbands, :password)
  @database Application.get_env(:exbands, :database)

  def connect do
    Postgrex.Connection.start_link(
      hostname: "localhost",
      username: @username,
      password: @password,
      database: @database
    )
  end

  def store_bands(bands, pid) do
    bands_query = build_bands_query(bands)
    pid |> Postgrex.Connection.query!("INSERT INTO artists \
      (name, created_at, updated_at) VALUES #{bands_query}", [])
  end

  def load_bands(pid) do
    pid
    |> Postgrex.Connection.query!("SELECT name FROM artists", [])
    |> Map.get(:rows)
    |> Enum.map &(List.first &1)
  end

  defp build_bands_query(bands) do
    datetime = formated_datetime
    bands
    |> Enum.map(&("('#{&1}', '#{datetime}', '#{datetime}')"))
    |> Enum.join(", ")
  end

  defp formated_datetime do
    {{y, m, d}, {h, min, s}} = :calendar.local_time()
    "#{y}-#{m}-#{d} #{h}:#{m}:#{s}"
  end
end
