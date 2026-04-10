defmodule Boldsign.User do
  @moduledoc """
  BoldSign User API.
  """

  @doc """
  Lists users.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/users/list", params: params).body
  end

  @doc """
  Gets a user's details.
  """
  def get(client, user_id) do
    Req.get!(client, url: "/users/get", params: [userId: user_id]).body
  end

  @doc """
  Invites a new user.
  """
  def create(client, params) do
    Req.post!(client, url: "/users/create", json: params).body
  end

  @doc """
  Updates a user's details.
  """
  def update(client, params) do
    Req.post!(client, url: "/users/update", json: params).body
  end

  @doc """
  Changes a user's team.
  """
  def change_team(client, params) do
    Req.post!(client, url: "/users/changeTeam", json: params).body
  end

  @doc """
  Resends an invitation to a user.
  """
  def resend_invitation(client, user_id) do
    Req.post!(client, url: "/users/resendInvitation", params: [userId: user_id]).body
  end

  @doc """
  Cancels a user's invitation.
  """
  def cancel_invitation(client, user_id) do
    Req.post!(client, url: "/users/cancelInvitation", params: [userId: user_id]).body
  end
end
