defmodule Travel.Flights.BatchOfferRequestsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/3" do
    test "sends POST to /air/batch_offer_requests with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/batch_offer_requests", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]
        assert length(data["slices"]) == 1
        assert hd(data["slices"])["origin"] == "LHR"
        assert hd(data["slices"])["destination"] == "JFK"
        assert length(data["passengers"]) == 1

        conn
        |> Plug.Conn.resp(200, create_batch_offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.BatchOfferRequests.create(config, %{
          slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
          passengers: [%{type: "adult"}]
        })

      assert response.status == 200
      assert %Travel.Flights.Types.CreateBatchOfferRequestResponse{} = response.data
      assert response.data.id == "bor_123"
      assert response.data.total_batches == 5
      assert response.data.remaining_batches == 5
    end

    test "passes supplier_timeout query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/batch_offer_requests", fn conn ->
        assert conn.query_string =~ "supplier_timeout=60"

        conn
        |> Plug.Conn.resp(200, create_batch_offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.BatchOfferRequests.create(
          config,
          %{
            slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
            passengers: [%{type: "adult"}]
          },
          %{supplier_timeout: 60}
        )

      assert response.status == 200
    end

    test "returns error on invalid request", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/batch_offer_requests", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid request parameters"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.BatchOfferRequests.create(config, %{
          slices: [],
          passengers: []
        })

      assert error.status == 400
    end
  end

  describe "get/2" do
    test "sends GET to /air/batch_offer_requests/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/batch_offer_requests/bor_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, batch_offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.BatchOfferRequests.get(config, "bor_123")

      assert response.status == 200
      assert %Travel.Flights.Types.BatchOfferRequest{} = response.data
      assert response.data.id == "bor_123"
      assert response.data.remaining_batches == 2
      assert length(response.data.offers) == 1
    end

    test "returns completed batch with offers", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/batch_offer_requests/bor_done", fn conn ->
        conn
        |> Plug.Conn.resp(200, completed_batch_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.BatchOfferRequests.get(config, "bor_done")

      assert response.status == 200
      assert %Travel.Flights.Types.BatchOfferRequest{} = response.data
      assert response.data.remaining_batches == 0
      assert length(response.data.offers) == 2
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/batch_offer_requests/bor_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Batch offer request not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.BatchOfferRequests.get(config, "bor_invalid")

      assert error.status == 404
    end
  end

  defp create_batch_offer_request_response do
    ~s({
      "data": {
        "id": "bor_123",
        "created_at": "2025-04-25T10:00:00Z",
        "live_mode": false,
        "client_key": "ck_test_123",
        "total_batches": 5,
        "remaining_batches": 5
      }
    })
  end

  defp batch_offer_request_response do
    ~s({
      "data": {
        "id": "bor_123",
        "created_at": "2025-04-25T10:00:00Z",
        "live_mode": false,
        "client_key": "ck_test_123",
        "total_batches": 5,
        "remaining_batches": 2,
        "offers": [{
          "id": "off_123",
          "owner": "BA",
          "total_amount": "300.00",
          "total_currency": "GBP",
          "base_amount": "250.00",
          "base_currency": "GBP",
          "tax_amount": "50.00",
          "tax_currency": "GBP",
          "created_at": "2025-04-25T10:00:00Z",
          "slices": [],
          "passengers": [],
          "available_payment_methods": ["balance"],
          "conditions": {"change_before_travel": {"allowed": true}},
          "live_mode": false,
          "updated_at": "2025-04-25T10:00:00Z",
          "expires_at": "2025-04-26T10:00:00Z",
          "supported_passenger_identity_documents": [],
          "partial_offers": []
        }]
      }
    })
  end

  defp completed_batch_response do
    ~s({
      "data": {
        "id": "bor_done",
        "created_at": "2025-04-25T10:00:00Z",
        "live_mode": false,
        "client_key": "ck_test_456",
        "total_batches": 3,
        "remaining_batches": 0,
        "offers": [
          {
            "id": "off_1",
            "owner": "BA",
            "total_amount": "300.00",
            "total_currency": "GBP",
            "base_amount": "250.00",
            "base_currency": "GBP",
            "tax_amount": "50.00",
            "tax_currency": "GBP",
            "created_at": "2025-04-25T10:00:00Z",
            "slices": [],
            "passengers": [],
            "available_payment_methods": ["balance"],
            "conditions": {"change_before_travel": {"allowed": true}},
            "live_mode": false,
            "updated_at": "2025-04-25T10:00:00Z",
            "expires_at": "2025-04-26T10:00:00Z",
            "supported_passenger_identity_documents": [],
            "partial_offers": []
          },
          {
            "id": "off_2",
            "owner": "VS",
            "total_amount": "350.00",
            "total_currency": "GBP",
            "base_amount": "290.00",
            "base_currency": "GBP",
            "tax_amount": "60.00",
            "tax_currency": "GBP",
            "created_at": "2025-04-25T10:00:00Z",
            "slices": [],
            "passengers": [],
            "available_payment_methods": ["balance"],
            "conditions": {"change_before_travel": {"allowed": false}},
            "live_mode": false,
            "updated_at": "2025-04-25T10:00:00Z",
            "expires_at": "2025-04-26T10:00:00Z",
            "supported_passenger_identity_documents": [],
            "partial_offers": []
          }
        ]
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
