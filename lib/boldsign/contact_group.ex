defmodule Boldsign.ContactGroup do
  @moduledoc """
  BoldSign Contact Group API.
  """

  @doc """
  Lists contact groups.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/contactGroups/list", query: params)
  end

  @doc """
  Gets a contact group's details.
  """
  def get(client, group_id) do
    Boldsign.Request.request!(client, :get, "/contactGroups/get", query: [groupId: group_id])
  end

  @doc """
  Creates a contact group.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/contactGroups/create", body: params)
  end

  @doc """
  Updates a contact group.
  """
  def update(client, group_id, params) do
    Boldsign.Request.request!(client, :put, "/contactGroups/update", query: [groupId: group_id], body: params)
  end

  @doc """
  Deletes a contact group.
  """
  def delete(client, group_id) do
    Boldsign.Request.request!(client, :delete, "/contactGroups/delete", query: [groupId: group_id])
  end
end
