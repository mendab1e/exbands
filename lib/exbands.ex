defmodule Exbands do
  @limit 2

  def start do
    Exbands.Lastfm.get_bands("a", @limit)
  end
end
