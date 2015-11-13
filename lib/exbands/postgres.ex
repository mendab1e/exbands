defmodule Exbands.Postgres do
  @username Application.get_env(:exbands, :username)
  @password Application.get_env(:exbands, :password)
  @database Application.get_env(:exbands, :database)
  @batch_size 1000

  def connect do
    Postgrex.Connection.start_link(
      hostname: "localhost",
      username: @username,
      password: @password,
      database: @database
    )
  end

  def store_bands([], _) do
    IO.puts "All bands have been written to db"
  end

  def store_bands(bands, pid) do
    {batch, remain_bands} = bands |> Enum.split @batch_size
    write_bands_to_db(batch, pid)
    store_bands(remain_bands, pid)
  end

  defp write_bands_to_db(bands, pid) do
    bands_query = build_bands_query(bands)
    Postgrex.Connection.query!(pid, "INSERT INTO artists \
      (name, created_at, updated_at) VALUES #{bands_query}", [])
    IO.puts "#{@batch_size} bands have been written"
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
    |> Enum.map(&(String.replace(&1, "'", "''")))
    |> Enum.map(&("('#{&1}', '#{datetime}', '#{datetime}')"))
    |> Enum.join(", ")
  end

  defp formated_datetime do
    {{y, m, d}, {h, min, s}} = :calendar.local_time()
    "#{y}-#{m}-#{d} #{h}:#{min}:#{s}"
  end
end
