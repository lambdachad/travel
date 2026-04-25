defmodule Travel.Flights.PaymentsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/payments with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/payments", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert data["order_id"] == "ord_123"
        assert data["payment"]["type"] == "balance"
        assert data["payment"]["amount"] == "500.00"

        conn
        |> Plug.Conn.resp(200, payment_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Payments.create(config, %{
          order_id: "ord_123",
          payment: %{type: "balance", amount: "500.00"}
        })

      assert response.status == 200
      assert %Travel.Flights.Types.Payment{} = response.data
      assert response.data.id == "pay_123"
      assert response.data.amount == "500.00"
      assert response.data.type == :balance
    end

    test "returns parsed Payment struct with all fields", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/payments", fn conn ->
        conn
        |> Plug.Conn.resp(200, payment_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Payments.create(config, %{
          order_id: "ord_123",
          payment: %{type: "balance", amount: "500.00"}
        })

      assert %Travel.Flights.Types.Payment{} = response.data
      assert response.data.id == "pay_123"
      assert response.data.amount == "500.00"
      assert response.data.currency == "GBP"
      assert response.data.type == :balance
      assert response.data.created_at == "2025-04-25T10:00:00Z"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/payments", fn conn ->
        conn
        |> Plug.Conn.resp(422, error_response("Order is not in a payable state"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Payments.create(config, %{
          order_id: "ord_paid",
          payment: %{type: "balance", amount: "500.00"}
        })

      assert error.status == 422
    end

    test "returns error on invalid order", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/payments", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Payments.create(config, %{
          order_id: "ord_invalid",
          payment: %{type: "balance", amount: "500.00"}
        })

      assert error.status == 404
    end
  end

  defp payment_response do
    ~s({
      "data": {
        "id": "pay_123",
        "amount": "500.00",
        "currency": "GBP",
        "type": "balance",
        "created_at": "2025-04-25T10:00:00Z"
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
