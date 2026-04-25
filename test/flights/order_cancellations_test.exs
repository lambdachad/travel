defmodule Travel.Flights.OrderCancellationsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/order_cancellations with order_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_cancellations", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["order_id"] == "ord_123"

        conn
        |> Plug.Conn.resp(200, cancellation_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.create(config, %{order_id: "ord_123"})

      assert response.status == 200
      assert %Travel.Flights.Types.OrderCancellation{} = response.data
      assert response.data.id == "ore_123"
      assert response.data.order_id == "ord_123"
      assert response.data.refund_amount == "150.00"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_cancellations", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Order cannot be cancelled"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.OrderCancellations.create(config, %{order_id: "ord_invalid"})

      assert error.status == 400
    end
  end

  describe "get/2" do
    test "sends GET to /air/order_cancellations/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_cancellations/ore_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, cancellation_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.get(config, "ore_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderCancellation{} = response.data
      assert response.data.id == "ore_123"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_cancellations/ore_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Cancellation not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderCancellations.get(config, "ore_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /air/order_cancellations", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_cancellations", fn conn ->
        conn
        |> Plug.Conn.resp(200, cancellations_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.OrderCancellation{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_cancellations", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, cancellations_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.list(config, %{limit: 10})

      assert response.status == 200
    end

    test "filters by order_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_cancellations", fn conn ->
        assert conn.query_string =~ "order_id=ord_123"

        conn
        |> Plug.Conn.resp(200, ~s({"data": []}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.list(config, %{order_id: "ord_123"})

      assert response.status == 200
      assert response.data == []
    end
  end

  describe "stream/2" do
    test "streams all pages of cancellations", %{bypass: bypass} do
      call_count = :atomics.new(1, [])

      Bypass.expect(bypass, fn conn ->
        cond do
          conn.request_path == "/air/order_cancellations" and conn.query_string == "" ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "ore_1", "order_id": "ord_1", "created_at": "2025-04-25T10:00:00Z", "confirmed_at": null, "expires_at": null, "live_mode": false, "refund_amount": "100.00", "refund_currency": "GBP", "refund_to": "original_form_of_payment", "airline_credits": []}], "meta": {"limit": 1, "after": "cursor_2"}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/air/order_cancellations" and
              String.contains?(conn.query_string, "after=cursor_2") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "ore_2", "order_id": "ord_2", "created_at": "2025-04-25T11:00:00Z", "confirmed_at": "2025-04-25T12:00:00Z", "expires_at": null, "live_mode": false, "refund_amount": "200.00", "refund_currency": "GBP", "refund_to": "original_form_of_payment", "airline_credits": []}], "meta": {"limit": 1, "after": null}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      config = travel_config(bypass.port)

      responses =
        Travel.Flights.OrderCancellations.stream(config)
        |> Enum.to_list()

      assert length(responses) == 2
      assert :atomics.get(call_count, 1) == 2
    end
  end

  describe "confirm/2" do
    test "sends POST to /air/order_cancellations/{id}/actions/confirm", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/air/order_cancellations/ore_123/actions/confirm",
        fn conn ->
          conn
          |> Plug.Conn.resp(200, confirmed_cancellation_response())
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderCancellations.confirm(config, "ore_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderCancellation{} = response.data
      assert response.data.confirmed_at == "2025-04-26T10:00:00Z"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/air/order_cancellations/ore_invalid/actions/confirm",
        fn conn ->
          conn
          |> Plug.Conn.resp(422, error_response("Cancellation already confirmed"))
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderCancellations.confirm(config, "ore_invalid")

      assert error.status == 422
    end
  end

  defp cancellation_response do
    ~s({"data": {
      "id": "ore_123",
      "order_id": "ord_123",
      "created_at": "2025-04-25T10:00:00Z",
      "confirmed_at": null,
      "expires_at": "2025-04-26T10:00:00Z",
      "live_mode": false,
      "refund_amount": "150.00",
      "refund_currency": "GBP",
      "refund_to": "original_form_of_payment",
      "airline_credits": []
    }})
  end

  defp confirmed_cancellation_response do
    ~s({"data": {
      "id": "ore_123",
      "order_id": "ord_123",
      "created_at": "2025-04-25T10:00:00Z",
      "confirmed_at": "2025-04-26T10:00:00Z",
      "expires_at": null,
      "live_mode": false,
      "refund_amount": "150.00",
      "refund_currency": "GBP",
      "refund_to": "original_form_of_payment",
      "airline_credits": []
    }})
  end

  defp cancellations_list_response do
    ~s({"data": [
      {"id": "ore_1", "order_id": "ord_1", "created_at": "2025-04-25T10:00:00Z", "confirmed_at": null, "expires_at": null, "live_mode": false, "refund_amount": "100.00", "refund_currency": "GBP", "refund_to": "original_form_of_payment", "airline_credits": []},
      {"id": "ore_2", "order_id": "ord_2", "created_at": "2025-04-25T11:00:00Z", "confirmed_at": "2025-04-25T12:00:00Z", "expires_at": null, "live_mode": false, "refund_amount": "200.00", "refund_currency": "GBP", "refund_to": "original_form_of_payment", "airline_credits": []}
    ]})
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
