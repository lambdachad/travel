defmodule Travel.Flights.OrderChangesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/order_changes with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_changes", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["selected_order_change_offer"] == "oco_123"

        conn
        |> Plug.Conn.resp(200, order_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.OrderChanges.create(config, %{
          selected_order_change_offer: "oco_123"
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChange{} = response.data
      assert response.data.id == "orc_123"
      assert response.data.order_id == "ord_123"
      assert response.data.change_total_amount == "50.00"
    end
  end

  describe "get/2" do
    test "sends GET to /air/order_changes/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_changes/orc_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, order_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChanges.get(config, "orc_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChange{} = response.data
      assert response.data.id == "orc_123"
      assert response.data.change_total_currency == "GBP"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_changes/orc_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order change not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderChanges.get(config, "orc_invalid")

      assert error.status == 404
    end
  end

  describe "confirm/3" do
    test "confirms order change without payment", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_changes/orc_123/actions/confirm", fn conn ->
        conn
        |> Plug.Conn.resp(200, confirmed_order_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChanges.confirm(config, "orc_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChange{} = response.data
      assert response.data.confirmed_at == "2025-04-25T12:00:00Z"
    end

    test "confirms order change with payment", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_changes/orc_123/actions/confirm", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]
        assert data["payment"]["amount"] == "50.00"
        assert data["payment"]["currency"] == "GBP"
        assert data["payment"]["type"] == "balance"

        conn
        |> Plug.Conn.resp(200, confirmed_order_change_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.OrderChanges.confirm(config, "orc_123", %{
          payment: %{
            amount: "50.00",
            currency: "GBP",
            type: "balance",
            three_d_secure_session_id: "3ds_123"
          }
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChange{} = response.data
    end

    test "returns error on invalid order change", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/air/order_changes/orc_invalid/actions/confirm",
        fn conn ->
          conn
          |> Plug.Conn.resp(400, error_response("Order change cannot be confirmed"))
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderChanges.confirm(config, "orc_invalid")

      assert error.status == 400
    end
  end

  defp order_change_response do
    ~s({
      "data": {
        "id": "orc_123",
        "order_id": "ord_123",
        "change_total_amount": "50.00",
        "change_total_currency": "GBP",
        "new_total_amount": "250.00",
        "new_total_currency": "GBP",
        "penalty_total_amount": "20.00",
        "penalty_total_currency": "GBP",
        "refund_to": "balance",
        "slices": {"add": [], "remove": []},
        "expires_at": "2025-05-01T12:00:00Z",
        "created_at": "2025-04-25T10:00:00Z",
        "confirmed_at": null,
        "live_mode": false,
        "available_payment_types": ["balance", "card"]
      }
    })
  end

  defp confirmed_order_change_response do
    ~s({
      "data": {
        "id": "orc_123",
        "order_id": "ord_123",
        "change_total_amount": "50.00",
        "change_total_currency": "GBP",
        "new_total_amount": "250.00",
        "new_total_currency": "GBP",
        "penalty_total_amount": "20.00",
        "penalty_total_currency": "GBP",
        "refund_to": "balance",
        "slices": {"add": [], "remove": []},
        "expires_at": "2025-05-01T12:00:00Z",
        "created_at": "2025-04-25T10:00:00Z",
        "confirmed_at": "2025-04-25T12:00:00Z",
        "live_mode": false,
        "available_payment_types": ["balance", "card"]
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
