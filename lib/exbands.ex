defmodule Exbands do
  alias Exbands.Postgres, as: Postgres
  alias Exbands.Lastfm, as: Lastfm
  @limit 1000

  def main do
    {:ok, pg_pid} = Postgres.connect
    bands_in_db = Postgres.load_bands(pg_pid)

    bands = Enum.to_list(?a..?z) ++ Enum.to_list(?а..?я)
    |> load_bands_from_lastfm
    |> (&(&1 -- bands_in_db)).()
    |> Postgres.store_bands(pg_pid)

    # bands |> Enum.count |> IO.puts
    # bands |> Enum.join(", ") |> IO.puts
  end

  defp load_bands_from_lastfm(letters) do
    letters
    |> Enum.map(&(spawn(Exbands, :bands_by_letter, [self, <<&1 :: utf8>>])))
    |> Enum.map(fn pid ->
         receive do {^pid, bands} -> bands end
       end)
    |> List.flatten
    |> Enum.uniq
  end

  def bands_by_letter(caller, letter) do
    bands = Lastfm.get_bands(letter, @limit)
    IO.puts "#{@limit} bands by letter #{letter} have been loaded from lastfm"
    send caller, {self, bands}
  end
end
