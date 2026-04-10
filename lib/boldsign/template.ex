defmodule Boldsign.Template do
  @moduledoc """
  BoldSign Template API.
  """

  @doc """
  Creates an embedded template preview URL.
  """
  def create_embedded_preview_url(client, template_id, params \\ %{}) do
    Req.post!(client, url: "/template/createEmbeddedPreviewUrl", params: [templateId: template_id], json: params).body
  end

  @doc """
  Lists templates.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/template/list", params: params).body
  end

  @doc """
  Sends a document using a template.
  """
  def send(client, template_id, params) do
    Req.post!(client, url: "/template/send", params: [templateId: template_id], json: params).body
  end

  @doc """
  Creates a template.
  """
  def create(client, params) do
    Req.post!(client, url: "/template/create", json: params).body
  end

  @doc """
  Edits a template.
  """
  def edit(client, template_id, params) do
    Req.post!(client, url: "/template/edit", params: [templateId: template_id], json: params).body
  end

  @doc """
  Deletes a template.
  """
  def delete(client, template_id) do
    Req.delete!(client, url: "/template/delete", params: [templateId: template_id]).body
  end

  @doc """
  Downloads a template.
  """
  def download(client, template_id) do
    Req.get!(client, url: "/template/download", params: [templateId: template_id]).body
  end

  @doc """
  Gets the properties of a template.
  """
  def get_properties(client, template_id) do
    Req.get!(client, url: "/template/properties", params: [templateId: template_id]).body
  end

  @doc """
  Merges and sends a document using multiple templates.
  """
  def merge_and_send(client, params) do
    Req.post!(client, url: "/template/mergeAndSend", json: params).body
  end
end
