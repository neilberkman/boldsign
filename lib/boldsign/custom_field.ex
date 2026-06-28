defmodule Boldsign.CustomField do
  @moduledoc """
  BoldSign Custom Field API.
  """

  @doc """
  Creates a custom field.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/customField/create", body: params)
  end

  @doc """
  Edits a custom field.
  """
  def edit(client, custom_field_id, params) do
    Boldsign.Request.request!(
      client,
      :post,
      "/customField/edit",
      query: [customFieldId: custom_field_id],
      body: params
    )
  end

  @doc """
  Deletes a custom field.
  """
  def delete(client, custom_field_id) do
    Boldsign.Request.request!(
      client,
      :delete,
      "/customField/delete",
      query: [customFieldId: custom_field_id]
    )
  end

  @doc """
  Lists custom fields for a brand.
  """
  def list(client, brand_id) do
    Boldsign.Request.request!(client, :get, "/customField/list", query: [brandId: brand_id])
  end

  @doc """
  Creates an embedded custom field designer URL.
  """
  def create_embedded_url(client, brand_id, params \\ []) do
    query = [{"BrandId", brand_id}] ++ Boldsign.Request.query_list(params)
    Boldsign.Request.request!(client, :post, "/customField/createEmbeddedCustomFieldUrl", query: query)
  end
end
