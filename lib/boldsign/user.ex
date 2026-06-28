defmodule Boldsign.User do
  @moduledoc """
  BoldSign User API.
  """

  @doc """
  Lists users.
  """
  def list(client, params \\ []) do
    Boldsign.Request.request!(client, :get, "/users/list", query: params)
  end

  @doc """
  Gets a user's details.
  """
  def get(client, user_id) do
    Boldsign.Request.request!(client, :get, "/users/get", query: [userId: user_id])
  end

  @doc """
  Invites a new user.
  """
  def create(client, params) do
    Boldsign.Request.request!(client, :post, "/users/create", body: params)
  end

  @doc """
  Updates a user's details.
  """
  def update(client, params) do
    Boldsign.Request.request!(client, :put, "/users/update", body: params)
  end

  @doc """
  Changes a user's team.
  """
  def change_team(client, params) when is_map(params) or is_list(params) do
    {user_id, body} = Boldsign.Request.pop_required_query_param(params, "userId", [:userId, "userId"])
    change_team(client, user_id, body)
  end

  def change_team(client, user_id, params) do
    Boldsign.Request.request!(
      client,
      :put,
      "/users/changeTeam",
      query: [userId: user_id],
      body: params
    )
  end

  @doc """
  Updates a user's metadata.
  """
  def update_metadata(client, params) do
    Boldsign.Request.request!(client, :put, "/users/updateMetaData", body: params)
  end

  @doc """
  Resends an invitation to a user.
  """
  def resend_invitation(client, user_id) do
    Boldsign.Request.request!(client, :post, "/users/resendInvitation", query: [{"UserId", user_id}])
  end

  @doc """
  Cancels a user's invitation.
  """
  def cancel_invitation(client, user_id) do
    Boldsign.Request.request!(client, :post, "/users/cancelInvitation", query: [{"UserId", user_id}])
  end
end
