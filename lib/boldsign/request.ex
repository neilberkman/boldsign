defmodule Boldsign.Request do
  @moduledoc false

  def request!(client, method, url, opts \\ []) do
    query = query_list(Keyword.get(opts, :query, []))
    body = Keyword.get(opts, :body)
    multipart? = Keyword.get(opts, :multipart, false) and multipart_body?(body)

    req_opts =
      [method: method, url: url]
      |> maybe_put_query(query)
      |> maybe_put_body(body, multipart?)

    Req.request!(client, req_opts).body
  end

  def query_list(nil), do: []
  def query_list(%{} = params), do: Enum.to_list(params)
  def query_list(params) when is_list(params), do: params

  def split_query_params(params, specs) do
    params = body_map(params)

    Enum.reduce(specs, {[], params}, fn {query_name, aliases}, {query, body} ->
      case pop_first(body, aliases) do
        {nil, body} -> {query, body}
        {value, body} -> {[{query_name, value} | query], body}
      end
    end)
    |> then(fn {query, body} -> {Enum.reverse(query), body} end)
  end

  def pop_required_query_param(params, query_name, aliases) do
    {value, body} = pop_first(body_map(params), aliases)

    if is_nil(value) do
      raise ArgumentError, "#{query_name} is required"
    end

    {value, body}
  end

  def body_map(%{} = params), do: params

  def body_map(params) when is_list(params) do
    if Keyword.keyword?(params), do: Map.new(params), else: params
  end

  def body_map(params), do: params

  defp maybe_put_query(req_opts, []), do: req_opts
  defp maybe_put_query(req_opts, query), do: Keyword.put(req_opts, :params, query)

  defp maybe_put_body(req_opts, nil, _multipart?), do: req_opts

  defp maybe_put_body(req_opts, body, true) do
    {raw_body, content_type} = Boldsign.Multipart.encode_raw(body_map(body))

    req_opts
    |> Keyword.put(:body, raw_body)
    |> Keyword.put(:headers, [{"content-type", content_type}])
  end

  defp maybe_put_body(req_opts, body, false), do: Keyword.put(req_opts, :json, body)

  defp multipart_body?(%{} = params), do: file_list?(Map.get(params, :files) || Map.get(params, "files"))

  defp multipart_body?(params) when is_list(params) do
    if Keyword.keyword?(params), do: file_list?(Keyword.get(params, :files)), else: false
  end

  defp multipart_body?(_), do: false

  defp file_list?(files) when is_list(files), do: files != []
  defp file_list?(_), do: false

  defp pop_first(params, aliases) do
    Enum.reduce_while(aliases, {nil, params}, fn alias_key, {_, body} ->
      if Map.has_key?(body, alias_key) do
        {:halt, {Map.fetch!(body, alias_key), Map.delete(body, alias_key)}}
      else
        {:cont, {nil, body}}
      end
    end)
  end
end
