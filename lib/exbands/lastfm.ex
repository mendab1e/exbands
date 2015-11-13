defmodule Exbands.Lastfm do
  @api_key Application.get_env(:exbands, :api_key)
  @wrong_api_key_error 10

  use HTTPoison.Base

  def get_bands(query, limit) do
    response = build_url(query, limit) |> get!
    response.body
  end

  defp build_url(band, limit) do
    "http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=#{band}\
      &api_key=#{@api_key}&format=json&limit=#{limit}"
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> match_bands
    |> Enum.reduce(HashDict.new, fn band, d -> Dict.put(d, band["name"], 1) end)
  end

  defp match_bands(%{"error" => @wrong_api_key_error, "message" => message}) do
    IO.puts "Error ##{@wrong_api_key_error}: #{message}"
    System.halt
  end

  defp match_bands(%{"error" => code, "message" => message}) do
    IO.puts "Error ##{code}: #{message}"
    []
  end

  defp match_bands(%{"results" => %{"artistmatches" => %{"artist" => bands}}}) do
    bands
  end
end
