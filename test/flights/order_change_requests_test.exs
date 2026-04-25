defmodule Travel.Flights.OrderChangeRequestsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/order_change_requests with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_change_requests", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]
        assert data["order_id"] == "ord_123"
        assert length(data["slices"]["add"]) == 1
        assert length(data["slices"]["remove"]) == 1

        conn
        |> Plug.Conn.resp(200, change_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.OrderChangeRequests.create(config, %{
          order_id: "ord_123",
          slices: %{
            add: [%{origin: "LHR", destination: "CDG", departure_date: "2025-07-01"}],
            remove: [%{slice_id: "sli_123"}]
          }
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChangeRequestResponse{} = response.data
      assert response.data.id == "ocr_123"
      assert response.data.order_id == "ord_123"
    end

    test "returns parsed response with order change offers", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_change_requests", fn conn ->
        conn
        |> Plug.Conn.resp(200, change_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.OrderChangeRequests.create(config, %{
          order_id: "ord_123",
          slices: %{
            add: [%{origin: "LHR", destination: "CDG", departure_date: "2025-07-01"}],
            remove: [%{slice_id: "sli_123"}]
          }
        })

      assert length(response.data.order_change_offers) == 1
      offer = hd(response.data.order_change_offers)
      assert %Travel.Flights.Types.OrderChangeOffer{} = offer
      assert offer.change_total_amount == "50.00"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/order_change_requests", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid order ID"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.OrderChangeRequests.create(config, %{
          order_id: "ord_invalid",
          slices: %{add: [], remove: []}
        })

      assert error.status == 400
    end
  end

  describe "get/2" do
    test "sends GET to /air/order_change_requests/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_requests/ocr_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, change_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChangeRequests.get(config, "ocr_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChangeRequestResponse{} = response.data
      assert response.data.id == "ocr_123"
      assert response.data.live_mode == false
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_requests/ocr_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Change request not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderChangeRequests.get(config, "ocr_invalid")

      assert error.status == 404
    end
  end

  defp change_request_response do
    ~s({"data": {
      "id": "ocr_123",
      "order_id": "ord_123",
      "live_mode": false,
      "slices": {"add": [], "remove": []},
      "order_change_offers": [{
        "id": "oco_123",
        "order_id": "ord_123",
        "change_total_amount": "50.00",
        "change_total_currency": "GBP",
        "new_total_amount": "200.00",
        "new_total_currency": "GBP",
        "penalty_total_amount": "25.00",
        "penalty_total_currency": "GBP",
        "refund_to": "original_form_of_payment",
        "slices": {"add": [], "remove": []},
        "expires_at": "2025-05-01T12:00:00Z",
        "created_at": "2025-04-25T10:00:00Z",
        "updated_at": null,
        "order_change_id": null
      }]
    }})
  end

  defp error_response(message) do
    ~s({
      "meta": {"request_id": "req_123"},
      "errors": [{"code": "not_found", "message": "#{message}", "title": "Not Found", "type": "invalid_request", "documentation_url": ""}]
    })
  end

  defp travel_config(port) do
    Travel.new(access_token: "test_token", base_url: "http://localhost:#{port}")
  end
end
