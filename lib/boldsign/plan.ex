defmodule Boldsign.Plan do
  @moduledoc """
  BoldSign Plan API.
  """

  @doc """
  Gets the available API credits.
  """
  def api_credits_count(client) do
    Boldsign.Request.request!(client, :get, "/plan/apiCreditsCount")
  end
end
