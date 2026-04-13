defmodule Boldsign.Multipart do
  @moduledoc """
  Converts a params map into `{key, value}` tuples for Req's
  `:form_multipart` option.

  BoldSign's multipart API uses bracket notation for nested objects:
  - `signers[0][name]` = `"Neil"`
  - `textTagDefinitions[0][type]` = `"Signature"`

  Files are extracted as `{"Files", {binary, opts}}` tuples.
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
    |> Enum.flat_map(fn {item, idx} -> flatten_list_item(key, idx, item) end)
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

  defp flatten_list_item(key, idx, item) when is_map(item) do
    Enum.map(item, fn {k, v} ->
      {"#{key}[#{idx}][#{k}]", to_string(v)}
    end)
  end

  defp flatten_list_item(key, idx, item) do
    [{"#{key}[#{idx}]", to_string(item)}]
  end
end
