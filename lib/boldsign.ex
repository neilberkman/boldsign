defmodule Boldsign do
  @moduledoc """
  BoldSign API Client.

  This client is built on top of [Req](https://github.com/wojtekmach/req).
  Following the "Small SDK" approach, `Boldsign.new/1` returns a `Req.Request`
  struct that can be used with `Req`'s functions or passed to the resource
  modules in this library.
  """

  @doc """
  Returns a new `Req.Request` pre-configured for BoldSign.

  ## Options

    * `:api_key` - (Required) Your BoldSign API key.
    * `:region` - (Optional) `:us` (default) or `:eu`.
    * `:base_url` - (Optional) Override the base URL.

  Remaining options are passed to `Req.new/1`.
  """
  def new(opts \\ []) do
    {api_key, opts} = Keyword.pop(opts, :api_key)
    {region, opts} = Keyword.pop(opts, :region, :us)
    {base_url, opts} = Keyword.pop(opts, :base_url, default_base_url(region))

    if is_nil(api_key) do
      raise ArgumentError, ":api_key is required"
    end

    Req.new(
      base_url: base_url,
      headers: [{"X-API-KEY", api_key}]
    )
    |> Req.merge(opts)
  end

  defp default_base_url(:us), do: "https://api.boldsign.com/v1"
  defp default_base_url(:eu), do: "https://api-eu.boldsign.com/v1"
end
