defmodule Exbands do
  alias Exbands.Postgres, as: Postgres
  alias Exbands.Lastfm, as: Lastfm
  @limit 10000

  def main(_argv) do
    start_time = :erlang.system_time
    {:ok, pg_pid} = Postgres.connect
    bands_in_db = Postgres.load_bands(pg_pid)

    bands = Enum.to_list(?a..?z) ++ Enum.to_list(?а..?я)
    |> load_bands_from_lastfm
    |> (&(&1 -- bands_in_db)).()

    bands_count = bands |> Enum.count
    bands |> Postgres.store_bands(pg_pid)

    IO.puts "#{bands_count} bands processed in #{bench_time(start_time)}ms"
  end

  defp load_bands_from_lastfm(letters) do
    letters
    |> Enum.map(&(spawn(Exbands, :bands_by_letter, [self, <<&1 :: utf8>>])))
    |> Enum.map(fn pid ->
         receive do
           {^pid, bands} -> bands
           after 20000 -> HashDict.new
         end
       end)
    |> Enum.reduce(HashDict.new, &Dict.merge/2)
    |> Dict.keys
  end

  def bands_by_letter(caller, letter) do
    bands = Lastfm.get_bands(letter, @limit)
    IO.puts "#{@limit} bands by letter #{letter} have been loaded from lastfm"

    send caller, {self, bands}
  end

  defp bench_time(t) do
    result = :erlang.system_time - t
    :erlang.convert_time_unit(result, :native, :milli_seconds)
  end
end
