defmodule Boldsign.PlanTest do
  use Boldsign.ApiCase, async: true

  test "api_credits_count/1 sends GET request", %{bypass: bypass, client: client} do
    Bypass.expect(bypass, "GET", "/v1/plan/apiCreditsCount", fn conn ->
      json_response(conn, 200, %{balanceCredits: 42})
    end)

    assert %{"balanceCredits" => 42} = Boldsign.Plan.api_credits_count(client)
  end
end
