defmodule Travel.Flights.AirlineInitiatedChangesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "list/2" do
    test "sends GET to /air/airline_initiated_changes with order_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_initiated_changes", fn conn ->
        assert conn.query_string =~ "order_id=ord_123"

        conn
        |> Plug.Conn.resp(200, airline_initiated_changes_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.list(config, "ord_123")

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.AirlineInitiatedChange{} = hd(response.data)
      assert hd(response.data).id == "aic_1"
    end

    test "returns empty list when no changes", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_initiated_changes", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s({"data": []}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.list(config, "ord_empty")

      assert response.status == 200
      assert response.data == []
    end

    test "returns error on invalid order", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_initiated_changes", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.AirlineInitiatedChanges.list(config, "ord_invalid")

      assert error.status == 404
    end
  end

  describe "accept/2" do
    test "sends POST to /air/airline_initiated_changes/{id}/actions/accept", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/air/airline_initiated_changes/aic_1/actions/accept",
        fn conn ->
          conn
          |> Plug.Conn.resp(200, accepted_change_response())
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineInitiatedChanges.accept(config, "aic_1")

      assert response.status == 200
      assert %Travel.Flights.Types.AirlineInitiatedChange{} = response.data
      assert response.data.id == "aic_1"
      assert response.data.action_taken == :accepted
    end

    test "returns error on already accepted change", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/air/airline_initiated_changes/aic_done/actions/accept",
        fn conn ->
          conn
          |> Plug.Conn.resp(400, error_response("Change has already been accepted"))
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.AirlineInitiatedChanges.accept(config, "aic_done")

      assert error.status == 400
    end
  end

  describe "update/3" do
    test "sends PATCH to /air/airline_initiated_changes/{id} with action_taken", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/airline_initiated_changes/aic_1", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["action_taken"] == "accepted"

        conn
        |> Plug.Conn.resp(200, accepted_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.AirlineInitiatedChanges.update(config, "aic_1", %{
          action_taken: "accepted"
        })

      assert response.status == 200
      assert %Travel.Flights.Types.AirlineInitiatedChange{} = response.data
      assert response.data.action_taken == :accepted
    end

    test "updates with cancelled action", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/airline_initiated_changes/aic_2", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["action_taken"] == "cancelled"

        conn
        |> Plug.Conn.resp(200, cancelled_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.AirlineInitiatedChanges.update(config, "aic_2", %{
          action_taken: "cancelled"
        })

      assert response.status == 200
      assert response.data.action_taken == :cancelled
    end

    test "returns error on invalid action", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/airline_initiated_changes/aic_1", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid action_taken value"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.AirlineInitiatedChanges.update(config, "aic_1", %{
          action_taken: "invalid"
        })

      assert error.status == 400
    end
  end

  defp airline_initiated_changes_list_response do
    ~s({"data": [
      {
        "id": "aic_1",
        "order_id": "ord_123",
        "action_taken": null,
        "action_taken_at": null,
        "created_at": "2025-04-25T10:00:00Z",
        "updated_at": "2025-04-25T10:00:00Z",
        "added": [{
          "id": "sli_new",
          "origin": "LHR",
          "destination": "JFK",
          "origin_type": "airport",
          "destination_type": "airport",
          "departure_date": "2025-06-02",
          "fare_brand_name": "Basic",
          "cabin_class_marketing_name": "Economy",
          "segments": []
        }],
        "removed": [{
          "id": "sli_old",
          "origin": "LHR",
          "destination": "JFK",
          "origin_type": "airport",
          "destination_type": "airport",
          "departure_date": "2025-06-01",
          "fare_brand_name": "Basic",
          "cabin_class_marketing_name": "Economy",
          "segments": []
        }],
        "available_actions": ["accept", "update"],
        "travel_agent_ticket": null
      },
      {
        "id": "aic_2",
        "order_id": "ord_123",
        "action_taken": null,
        "action_taken_at": null,
        "created_at": "2025-04-25T11:00:00Z",
        "updated_at": "2025-04-25T11:00:00Z",
        "added": [],
        "removed": [],
        "available_actions": ["accept", "update"],
        "travel_agent_ticket": null
      }
    ]})
  end

  defp accepted_change_response do
    ~s({
      "data": {
        "id": "aic_1",
        "order_id": "ord_123",
        "action_taken": "accepted",
        "action_taken_at": "2025-04-25T12:00:00Z",
        "created_at": "2025-04-25T10:00:00Z",
        "updated_at": "2025-04-25T12:00:00Z",
        "added": [],
        "removed": [],
        "available_actions": [],
        "travel_agent_ticket": null
      }
    })
  end

  defp cancelled_change_response do
    ~s({
      "data": {
        "id": "aic_2",
        "order_id": "ord_123",
        "action_taken": "cancelled",
        "action_taken_at": "2025-04-25T12:00:00Z",
        "created_at": "2025-04-25T11:00:00Z",
        "updated_at": "2025-04-25T12:00:00Z",
        "added": [],
        "removed": [],
        "available_actions": [],
        "travel_agent_ticket": null
      }
    })
  end

  defp error_response(message) do
    ~s({
      "meta": {"request_id": "req_123"},
      "errors": [{"code": "invalid_request", "message": "#{message}", "title": "Bad Request", "type": "validation_error", "documentation_url": ""}]
    })
  end

  defp travel_config(port) do
    Travel.new(access_token: "test_token", base_url: "http://localhost:#{port}")
  end
end
