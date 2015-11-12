defmodule Exbands do
  @limit 1

  def main do
    {:ok, pg_pid} = Exbands.Postgres.connect

    bands = Enum.to_list(?a..?z) ++ Enum.to_list(?а..?я)
    |> load_bands

    bands |> Enum.count |> IO.puts
    bands |> Enum.join(", ") |> IO.puts
  end

  defp load_bands(letters) do
    letters
    |> Enum.map(&(spawn(Exbands, :bands_by_letter, [self, <<&1 :: utf8>>])))
    |> Enum.map(fn pid ->
         receive do {^pid, bands} -> bands end
       end)
    |> List.flatten
  end

  def bands_by_letter(caller, letter) do
    send caller, {self, Exbands.Lastfm.get_bands(letter, @limit)}
  end
end
