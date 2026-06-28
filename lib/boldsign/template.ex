defmodule Boldsign.Template do
  @moduledoc """
  BoldSign Template API.
  """

  @doc """
  Creates an embedded template preview URL.
  """
  def create_embedded_preview_url(client, template_id, params \\ %{}) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/createEmbeddedPreviewUrl",
      query: [templateId: template_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Lists templates.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/template/list", query: params)
  end

  @doc """
  Sends a document using a template.
  """
  def send(client, template_id, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/send",
      query: [templateId: template_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Creates a template.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/template/create", body: params, multipart: true)
  end

  @doc """
  Edits a template.
  """
  def edit(client, template_id, params) do
    Boldsign.Request.request!(
      client,
      :put,
      "/template/edit",
      query: [templateId: template_id],
      body: params
    )
  end

  @doc """
  Deletes a template.
  """
  def delete(client, template_id, params \\ []) do
    query = [templateId: template_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :delete, "/template/delete", query: query)
  end

  @doc """
  Downloads a template.
  """
  def download(client, template_id, params \\ []) do
    query = [templateId: template_id] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :get, "/template/download", query: query)
  end

  @doc """
  Gets the properties of a template.
  """
  def get_properties(client, template_id) do
    Boldsign.Request.request!(client, :get, "/template/properties", query: [templateId: template_id])
  end

  @doc """
  Adds tags to a template.
  """
  def add_tags(client, params) do
    Boldsign.Request.request!(client, :patch, "/template/addTags", body: params)
  end

  @doc """
  Deletes tags from a template.
  """
  def delete_tags(client, params) do
    Boldsign.Request.request!(client, :delete, "/template/deleteTags", body: params)
  end

  @doc """
  Creates an embedded send URL from a template.
  """
  def create_embedded_request_url(client, template_id, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/createEmbeddedRequestUrl",
      query: [templateId: template_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Creates an embedded template designer URL.
  """
  def create_embedded_template_url(client, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/createEmbeddedTemplateUrl",
      body: params,
      multipart: true
    )
  end

  @doc """
  Creates an embedded edit URL for a template.
  """
  def get_embedded_template_edit_url(client, template_id, params \\ %{}) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/getEmbeddedTemplateEditUrl",
      query: [templateId: template_id],
      body: params,
      multipart: true
    )
  end

  @doc """
  Merges and sends a document using multiple templates.
  """
  def merge_and_send(client, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/mergeAndSend",
      body: params,
      multipart: true
    )
  end

  @doc """
  Creates an embedded merge-and-send URL.
  """
  def merge_create_embedded_request_url(client, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/template/mergeCreateEmbeddedRequestUrl",
      body: params,
      multipart: true
    )
  end
end
