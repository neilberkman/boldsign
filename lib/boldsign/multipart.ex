defmodule Boldsign.Multipart do
  @moduledoc """
  Converts a params map into a raw multipart/form-data binary.

  BoldSign's multipart API uses bracket notation for nested objects:
  - `signers[0][name]` = `"Neil"`
  - `signers[0][formFields][0][bounds][x]` = `"50"`

  Recursively flattens arbitrarily nested maps and lists. Use `encode_raw/1`
  to build the request body and content-type header directly, avoiding
  `String.to_atom/1` on dynamic bracket-notation field names.
  """

  @crlf "\r\n"

  @doc """
  Encodes params as a raw multipart/form-data binary.

  Returns `{body, content_type}` where `body` is the encoded binary and
  `content_type` is `"multipart/form-data; boundary=BOUNDARY"`.

  Use with Req's `:body` option and set the `content-type` header manually:

      {body, content_type} = Boldsign.Multipart.encode_raw(params)
      Req.post!(client, url: "/some/endpoint", body: body, headers: [{"content-type", content_type}])
  """
  def encode_raw(params) when is_map(params) do
    {file_parts, field_parts} = encode(params)

    boundary = Base.encode16(:crypto.strong_rand_bytes(16), padding: false, case: :lower)

    parts =
      Enum.flat_map(field_parts, fn {name, value} ->
        [
          "--",
          boundary,
          @crlf,
          "Content-Disposition: form-data; name=\"",
          escape_param(name),
          "\"",
          @crlf,
          @crlf,
          to_string(value),
          @crlf
        ]
      end) ++
        Enum.flat_map(file_parts, fn {_field, {binary, opts}} ->
          filename = Keyword.get(opts, :filename, "document.pdf")
          content_type = Keyword.get(opts, :content_type, "application/octet-stream")

          [
            "--",
            boundary,
            @crlf,
            "Content-Disposition: form-data; name=\"Files\"; filename=\"",
            escape_param(filename),
            "\"",
            @crlf,
            "Content-Type: ",
            content_type,
            @crlf,
            @crlf,
            binary,
            @crlf
          ]
        end) ++
        ["--", boundary, "--", @crlf]

    body = IO.iodata_to_binary(parts)
    content_type = "multipart/form-data; boundary=#{boundary}"
    {body, content_type}
  end

  @doc """
  Splits files from params and returns `{file_parts, field_parts}`.
  """
  def encode(params) when is_map(params) do
    {files, rest} =
      case Map.pop(params, :files) do
        {nil, params} -> Map.pop(params, "files", [])
        result -> result
      end

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

  defp flatten_value(prefix, []) do
    [{prefix, "[]"}]
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

  defp escape_param(value) when is_binary(value) do
    URI.encode(value, &(&1 not in [?", ?\r, ?\n]))
  end
end
