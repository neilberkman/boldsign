defmodule Boldsign.Multipart do
  @moduledoc """
  Converts a params map into `{key, value}` tuples for Req's
  `:form_multipart` option.

  BoldSign's multipart API uses bracket notation for nested objects:
  - `signers[0][name]` = `"Neil"`
  - `signers[0][formFields][0][bounds][x]` = `"50"`

  Recursively flattens arbitrarily nested maps and lists.
  """

  @doc """
  Splits files from params and returns `{file_parts, field_parts}`.
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
  Flattens a map into form field tuples with recursive bracket notation.
  """
  def flatten(params) when is_map(params) do
    Enum.flat_map(params, fn {key, value} ->
      flatten_value(to_string(key), value)
    end)
  end

  defp flatten_value(prefix, values) when is_list(values) do
    values
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, idx} ->
      flatten_value("#{prefix}[#{idx}]", item)
    end)
  end

  defp flatten_value(prefix, value) when is_map(value) do
    Enum.flat_map(value, fn {k, v} ->
      flatten_value("#{prefix}[#{k}]", v)
    end)
  end

  defp flatten_value(prefix, value) when is_boolean(value) do
    [{prefix, to_string(value)}]
  end

  defp flatten_value(prefix, value) do
    [{prefix, to_string(value)}]
  end
end
