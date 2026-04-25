defmodule Travel.Flights.OfferRequestsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/3" do
    test "sends POST to /air/offer_requests", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/offer_requests", fn conn ->
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
        Travel.Flights.OfferRequests.create(config, %{
          slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
          passengers: [%{type: "adult"}]
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
      assert response.data.id == "orq_123"
    end

    test "sends return_offers as query param when provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/offer_requests", fn conn ->
        assert conn.query_string =~ "return_offers=true"

        conn
        |> Plug.Conn.resp(200, offer_request_with_offers_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.OfferRequests.create(
          config,
          %{
            slices: [%{origin: "LHR", destination: "JFK", departure_date: "2025-06-01"}],
            passengers: [%{type: "adult"}]
          },
          %{return_offers: true}
        )

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
      assert length(response.data.offers) == 1
      assert %Travel.Flights.Types.Offer{} = hd(response.data.offers)
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/offer_requests", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid offer request parameters"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.OfferRequests.create(config, %{
          slices: [],
          passengers: []
        })

      assert error.status == 400
    end
  end

  describe "get/2" do
    test "sends GET to /air/offer_requests/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offer_requests/orq_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, offer_request_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OfferRequests.get(config, "orq_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OfferRequest{} = response.data
      assert response.data.id == "orq_123"
      assert response.data.cabin_class == :economy
      assert length(response.data.slices) == 1
      assert length(response.data.passengers) == 1
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offer_requests/orq_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Offer request not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OfferRequests.get(config, "orq_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /air/offer_requests", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offer_requests", fn conn ->
        conn
        |> Plug.Conn.resp(200, offer_requests_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OfferRequests.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.OfferRequest{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offer_requests", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, offer_requests_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OfferRequests.list(config, %{limit: 10})

      assert response.status == 200
    end
  end

  describe "stream/2" do
    test "streams all pages of offer requests", %{bypass: bypass} do
      call_count = :atomics.new(1, [])

      Bypass.expect(bypass, fn conn ->
        cond do
          conn.request_path == "/air/offer_requests" and conn.query_string == "" ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "orq_1", "live_mode": false, "created_at": "2025-04-25T10:00:00Z", "slices": [{"origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "time_zone": "Europe/London", "iata_code": "LHR", "iata_country_code": "GB", "city_name": "London"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "time_zone": "America/New_York", "iata_code": "JFK", "iata_country_code": "US", "city_name": "New York"}, "departure_date": "2025-06-01"}], "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}], "cabin_class": null, "max_connections": null, "private_fares": [], "offers": []}], "meta": {"limit": 1, "after": "cursor_2"}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/air/offer_requests" and
              String.contains?(conn.query_string, "after=cursor_2") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "orq_2", "live_mode": false, "created_at": "2025-04-25T11:00:00Z", "slices": [{"origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "time_zone": "Europe/London", "iata_code": "LHR", "iata_country_code": "GB", "city_name": "London"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "time_zone": "America/New_York", "iata_code": "JFK", "iata_country_code": "US", "city_name": "New York"}, "departure_date": "2025-06-01"}], "passengers": [{"id": "pas_2", "age": null, "type": "adult", "given_name": null, "family_name": null}], "cabin_class": null, "max_connections": null, "private_fares": [], "offers": []}], "meta": {"limit": 1, "after": null}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      config = travel_config(bypass.port)

      responses =
        Travel.Flights.OfferRequests.stream(config)
        |> Enum.to_list()

      assert length(responses) == 2
      assert :atomics.get(call_count, 1) == 2
      assert %Travel.Flights.Types.OfferRequest{} = hd(responses).data |> hd()
    end
  end

  defp offer_request_response do
    ~s({
      "data": {
        "id": "orq_123",
        "live_mode": false,
        "created_at": "2025-04-25T10:00:00Z",
        "slices": [{
          "origin_type": "airport",
          "destination_type": "airport",
          "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "time_zone": "Europe/London", "iata_code": "LHR", "iata_country_code": "GB", "city_name": "London"},
          "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "time_zone": "America/New_York", "iata_code": "JFK", "iata_country_code": "US", "city_name": "New York"},
          "departure_date": "2025-06-01"
        }],
        "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}],
        "cabin_class": "economy",
        "max_connections": 1,
        "private_fares": [],
        "offers": []
      }
    })
  end

  defp offer_request_with_offers_response do
    ~s({
      "data": {
        "id": "orq_123",
        "live_mode": false,
        "created_at": "2025-04-25T10:00:00Z",
        "slices": [{
          "origin_type": "airport",
          "destination_type": "airport",
          "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"},
          "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"},
          "departure_date": "2025-06-01"
        }],
        "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}],
        "cabin_class": null,
        "max_connections": null,
        "private_fares": [],
        "offers": [{
          "id": "off_123",
          "owner": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"},
          "total_amount": "500.00",
          "total_currency": "GBP",
          "base_amount": "400.00",
          "base_currency": "GBP",
          "tax_amount": "100.00",
          "tax_currency": "GBP",
          "expires_at": "2025-04-25T11:00:00Z",
          "slices": [{
            "id": "sli_123",
            "origin_type": "airport",
            "destination_type": "airport",
            "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"},
            "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"},
            "duration": "PT8H",
            "fare_brand_name": "Economy Basic",
            "segments": [{
              "id": "seg_123",
              "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"},
              "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"},
              "departing_at": "2025-06-01T10:00:00Z",
              "arriving_at": "2025-06-01T18:00:00Z",
              "duration": "PT8H",
              "marketing_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"},
              "operating_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"},
              "marketing_carrier_flight_number": "123",
              "passengers": [{"passenger_id": "pas_1", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T123", "baggages": []}],
              "stops": []
            }],
            "conditions": {},
            "ngs_shelf": 1
          }],
          "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}],
          "conditions": {},
          "available_services": [],
          "private_fares": [],
          "payment_requirements": {"payment_required_by": null, "price_guarantee_expires_at": null, "requires_instant_payment": true},
          "partial": false,
          "supported_loyalty_programmes": [],
          "supported_passenger_identity_document_types": [],
          "total_emissions_kg": "200.0",
          "live_mode": false,
          "created_at": "2025-04-25T10:00:00Z",
          "updated_at": null
        }]
      }
    })
  end

  defp offer_requests_list_response do
    ~s({"data": [
      {"id": "orq_1", "live_mode": false, "created_at": "2025-04-25T10:00:00Z", "slices": [{"origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departure_date": "2025-06-01"}], "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}], "cabin_class": null, "max_connections": null, "private_fares": [], "offers": []},
      {"id": "orq_2", "live_mode": false, "created_at": "2025-04-25T11:00:00Z", "slices": [{"origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departure_date": "2025-06-01"}], "passengers": [{"id": "pas_2", "age": null, "type": "adult", "given_name": null, "family_name": null}], "cabin_class": null, "max_connections": null, "private_fares": [], "offers": []}
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
