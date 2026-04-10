defmodule Boldsign.File do
  @moduledoc """
  Helper for preparing files for upload.
  """

  @doc """
  Prepares a file for upload using multi-part form data.
  """
  def from_path(path) do
    filename = Path.basename(path)
    content_type = MIME.from_path(path)

    {:file, path, filename: filename, content_type: content_type}
  end

  def from_binary(binary, filename, content_type \\ "application/octet-stream") do
    {:binary, binary, filename: filename, content_type: content_type}
  end
end
