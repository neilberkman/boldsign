defmodule Boldsign.Document do
  @moduledoc """
  BoldSign Document API.
  """

  @doc """
  Sends a document for signature.
  """
  def send(client, params) do
    Req.post!(client, url: "/document/send", json: params).body
  end

  @doc """
  Creates a document draft.
  """
  def create(client, params) do
    Req.post!(client, url: "/document/create", json: params).body
  end

  @doc """
  Edits a document.
  """
  def edit(client, params) do
    Req.post!(client, url: "/document/edit", json: params).body
  end

  @doc """
  Deletes a document.
  """
  def delete(client, document_id) do
    Req.delete!(client, url: "/document/delete", params: [documentId: document_id]).body
  end

  @doc """
  Downloads a document.
  """
  def download(client, document_id) do
    Req.get!(client, url: "/document/download", params: [documentId: document_id]).body
  end

  @doc """
  Gets the properties of a document.
  """
  def get_properties(client, document_id) do
    Req.get!(client, url: "/document/properties", params: [documentId: document_id]).body
  end

  @doc """
  Lists documents.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/document/list", params: params).body
  end

  @doc """
  Reminds signers about a document.
  """
  def remind(client, document_id, params \\ %{}) do
    Req.post!(client, url: "/document/remind", params: [documentId: document_id], json: params).body
  end

  @doc """
  Revokes a document.
  """
  def revoke(client, document_id, params \\ %{}) do
    Req.post!(client, url: "/document/revoke", params: [documentId: document_id], json: params).body
  end

  @doc """
  Creates an embedded signing link.
  """
  def get_embedded_sign_link(client, document_id, params) do
    Req.get!(client, url: "/document/getEmbeddedSignLink", params: Keyword.merge([documentId: document_id], params)).body
  end

  @doc """
  Creates an embedded edit URL for a document.
  """
  def create_embedded_edit_url(client, document_id, params \\ %{}) do
    Req.post!(client, url: "/document/createEmbeddedEditUrl", params: [documentId: document_id], json: params).body
  end

  @doc """
  Creates an embedded request URL.
  """
  def create_embedded_request_url(client, params) do
    Req.post!(client, url: "/document/createEmbeddedRequestUrl", json: params).body
  end
end
