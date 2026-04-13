defmodule Boldsign.Multipart do
  @moduledoc """
  Converts a params map into `{key, value}` tuples for Req's
  `:form_multipart` option.

  Follows BoldSign's official SDK conventions:
  - Files are extracted and encoded as `{"Files", binary, opts}`
  - Lists of complex objects → indexed keys with JSON-stringified values
    (`signers[0]` = `{"name":"Jo","emailAddress":"jo@x.com"}`)
  - Lists of primitives → indexed keys with string values
  - Dicts → bracket keys (`metaData[key]` = `value`)
  - Booleans → `"true"` / `"false"`
  - Everything else → `to_string`
  """

  @doc """
  Splits files from params and returns `{file_parts, field_parts}` ready
  for `Req.post!(client, form_multipart: file_parts ++ field_parts)`.
  """
  def encode(params) when is_map(params) do
    {files, rest} = Map.pop(params, :files, [])

    file_parts =
      files
      |> Enum.with_index()
      |> Enum.map(fn {file, idx} ->
        case file do
          {:binary, binary, opts} ->
            filename = Keyword.get(opts, :filename, "document_#{idx}.pdf")
            content_type = Keyword.get(opts, :content_type, "application/pdf")
            {"Files", {binary, filename: filename, content_type: content_type}}

          {:file, path, opts} ->
            filename = Keyword.get(opts, :filename, Path.basename(path))
            content_type = Keyword.get(opts, :content_type, "application/pdf")
            {"Files", {File.read!(path), filename: filename, content_type: content_type}}
        end
      end)

    field_parts = flatten(rest)

    {file_parts, field_parts}
  end

  @doc """
  Flattens a map into form field tuples. Matches the serialization
  approach used by BoldSign's official Node.js and Python SDKs.
  """
  def flatten(params) when is_map(params) do
    Enum.flat_map(params, fn {key, value} ->
      flatten_field(to_string(key), value)
    end)
  end

  defp flatten_field(key, values) when is_list(values) do
    values
    |> Enum.with_index()
    |> Enum.map(fn {item, idx} ->
      if is_map(item) do
        {"#{key}[#{idx}]", Jason.encode!(item)}
      else
        {"#{key}[#{idx}]", to_string(item)}
      end
    end)
  end

  defp flatten_field(key, value) when is_map(value) do
    Enum.map(value, fn {k, v} ->
      {"#{key}[#{k}]", to_string(v)}
    end)
  end

  defp flatten_field(key, value) when is_boolean(value) do
    [{key, to_string(value)}]
  end

  defp flatten_field(key, value) do
    [{key, to_string(value)}]
  end
end
