defmodule Boldsign.Team do
  @moduledoc """
  BoldSign Team API.
  """

  @doc """
  Lists teams.
  """
  def list(client, params \\ []) do
    Req.get!(client, url: "/teams/list", params: params).body
  end

  @doc """
  Gets a team's details.
  """
  def get(client, team_id) do
    Req.get!(client, url: "/teams/get", params: [teamId: team_id]).body
  end

  @doc """
  Creates a new team.
  """
  def create(client, params) do
    Req.post!(client, url: "/teams/create", json: params).body
  end

  @doc """
  Updates a team's details.
  """
  def update(client, params) do
    Req.post!(client, url: "/teams/update", json: params).body
  end
end
