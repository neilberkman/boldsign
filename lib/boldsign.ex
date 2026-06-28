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

    * `:api_key` - (Optional) Your BoldSign API key.
    * `:access_token` - (Optional) Your BoldSign OAuth access token.
    * `:region` - (Optional) `:us` (default), `:eu`, `:ca`, or `:au`.
    * `:base_url` - (Optional) Override the base URL.

  Remaining options are passed to `Req.new/1`.
  """
  def new(opts \\ []) do
    {api_key, opts} = Keyword.pop(opts, :api_key)
    {access_token, opts} = Keyword.pop(opts, :access_token)
    {region, opts} = Keyword.pop(opts, :region, :us)
    {base_url, opts} = Keyword.pop(opts, :base_url, default_base_url(region))

    if is_nil(api_key) and is_nil(access_token) do
      raise ArgumentError, ":api_key or :access_token is required"
    end

    Req.new(base_url: base_url, headers: build_headers(api_key, access_token))
    |> Req.merge(opts)
  end

  defp default_base_url(:us), do: "https://api.boldsign.com/v1"
  defp default_base_url(:eu), do: "https://eu-api.boldsign.com/v1"
  defp default_base_url(:ca), do: "https://ca-api.boldsign.com/v1"
  defp default_base_url(:au), do: "https://au-api.boldsign.com/v1"

  defp build_headers(api_key, access_token) do
    []
    |> maybe_put_api_key(api_key)
    |> maybe_put_access_token(access_token)
  end

  defp maybe_put_api_key(headers, nil), do: headers
  defp maybe_put_api_key(headers, api_key), do: [{"X-API-KEY", api_key} | headers]

  defp maybe_put_access_token(headers, nil), do: headers
  defp maybe_put_access_token(headers, access_token), do: [{"Authorization", "Bearer #{access_token}"} | headers]
end
