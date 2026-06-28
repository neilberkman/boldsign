defmodule Boldsign.Contact do
  @moduledoc """
  BoldSign Contact API.
  """

  @doc """
  Lists contacts.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/contacts/list", query: params)
  end

  @doc """
  Gets a contact's details.
  """
  def get(client, contact_id) do
    Boldsign.Request.request!(client, :get, "/contacts/get", query: [id: contact_id])
  end

  @doc """
  Creates contacts.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/contacts/create", body: params)
  end

  @doc """
  Updates a contact.
  """
  def update(client, contact_id, params) do
    Boldsign.Request.request!(client, :put, "/contacts/update", query: [id: contact_id], body: params)
  end

  @doc """
  Deletes a contact.
  """
  def delete(client, contact_id) do
    Boldsign.Request.request!(client, :delete, "/contacts/delete", query: [id: contact_id])
  end
end
