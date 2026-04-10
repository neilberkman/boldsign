defmodule Boldsign.Brand do
  @moduledoc """
  BoldSign Brand API.
  """

  @doc """
  Lists brands.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/brand/list", params: params).body
  end

  @doc """
  Gets a brand's details.
  """
  def get(client, brand_id) do
    Req.get!(client, url: "/brand/get", params: [brandId: brand_id]).body
  end

  @doc """
  Creates a new brand.
  """
  def create(client, params) do
    Req.post!(client, url: "/brand/create", json: params).body
  end

  @doc """
  Edits a brand's details.
  """
  def edit(client, brand_id, params) do
    Req.post!(client, url: "/brand/edit", params: [brandId: brand_id], json: params).body
  end

  @doc """
  Deletes a brand.
  """
  def delete(client, brand_id) do
    Req.delete!(client, url: "/brand/delete", params: [brandId: brand_id]).body
  end

  @doc """
  Resets a brand to default.
  """
  def reset_default(client, brand_id) do
    Req.post!(client, url: "/brand/resetdefault", params: [brandId: brand_id]).body
  end
end
