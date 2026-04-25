defmodule Travel.Flights.PartialOfferRequestsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/3" do
    test "sends POST to /air/partial_offer_requests with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/partial_offer_requests", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]
        assert length(data["slices"]) == 1
        assert hd(data["slices"])["origin"] == "LHR"
        assert hd(data["slices"])["destination"] == "JFK"
        assert length(data["passengers"]) == 1

        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.PartialOfferRequests.create(config, %{
          slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
          passengers: [%{type: "adult"}]
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
      assert response.data.id == "por_123"
      assert length(response.data.slices) == 1
    end

    test "passes supplier_timeout query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/partial_offer_requests", fn conn ->
        assert conn.query_string =~ "supplier_timeout=30"

        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.PartialOfferRequests.create(
          config,
          %{
            slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
            passengers: [%{type: "adult"}]
          },
          %{supplier_timeout: 30}
        )

      assert response.status == 200
    end

    test "returns error on invalid request", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/partial_offer_requests", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid slices"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.PartialOfferRequests.create(config, %{
          slices: [],
          passengers: []
        })

      assert error.status == 400
    end
  end

  describe "get/3" do
    test "sends GET to /air/partial_offer_requests/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/partial_offer_requests/por_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.PartialOfferRequests.get(config, "por_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
      assert response.data.id == "por_123"
      assert length(response.data.offers) == 1
    end

    test "passes selected_partial_offer query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/partial_offer_requests/por_123", fn conn ->
        assert conn.query_string =~ "selected_partial_offer=off_123"

        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.PartialOfferRequests.get(config, "por_123", %{
          selected_partial_offer: "off_123"
        })

      assert response.status == 200
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/partial_offer_requests/por_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Partial offer request not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.PartialOfferRequests.get(config, "por_invalid")

      assert error.status == 404
    end
  end

  describe "get_fares_by_id/3" do
    test "sends GET to /air/partial_offer_requests/{id}/fares", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/partial_offer_requests/por_123/fares", fn conn ->
        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.PartialOfferRequests.get_fares_by_id(config, "por_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
    end

    test "passes selected_partial_offer query param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/partial_offer_requests/por_123/fares", fn conn ->
        assert conn.query_string =~ "selected_partial_offer=off_456"

        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.PartialOfferRequests.get_fares_by_id(config, "por_123", %{
          selected_partial_offer: "off_456"
        })

      assert response.status == 200
    end

    test "returns error on invalid request", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "GET",
        "/air/partial_offer_requests/por_invalid/fares",
        fn conn ->
          conn
          |> Plug.Conn.resp(422, error_response("No fares available"))
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.PartialOfferRequests.get_fares_by_id(config, "por_invalid")

      assert error.status == 422
    end
  end

  defp offer_request_response do
    ~s({
      "data": {
        "id": "por_123",
        "live_mode": false,
        "created_at": "2025-04-25T10:00:00Z",
        "slices": [{
          "origin": "LHR",
          "destination": "JFK",
          "departure_date": "2025-06-01",
          "origin_type": "airport",
          "destination_type": "airport",
          "partial_offers": [{"id": "poff_1", "offer_segments": []}]
        }],
        "passengers": [{"id": "pas_1", "type": "adult", "age": 30}],
        "cabin_class": "economy",
        "max_connections": null,
        "private_fares": [],
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
