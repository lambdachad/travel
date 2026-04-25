defmodule Travel.Flights.OffersTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "get/3" do
    test "sends GET to /air/offers/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers/off_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, offer_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Offers.get(config, "off_123")

      assert response.status == 200
      assert %Travel.Flights.Types.Offer{} = response.data
      assert response.data.id == "off_123"
      assert response.data.total_amount == "500.00"
      assert response.data.total_currency == "GBP"
      assert length(response.data.slices) == 1
      assert length(response.data.passengers) == 1
    end

    test "passes query params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers/off_123", fn conn ->
        assert conn.query_string =~ "return_available_services=true"

        conn
        |> Plug.Conn.resp(200, offer_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Offers.get(config, "off_123", %{return_available_services: true})

      assert response.status == 200
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers/off_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Offer not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.Offers.get(config, "off_invalid")

      assert error.status == 404
    end
  end

  describe "list/3" do
    test "sends GET to /air/offers with offer_request_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers", fn conn ->
        assert conn.query_string =~ "offer_request_id=orq_123"

        conn
        |> Plug.Conn.resp(200, offers_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Offers.list(config, "orq_123")

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.Offer{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers", fn conn ->
        assert conn.query_string =~ "offer_request_id=orq_123"
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, offers_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Offers.list(config, "orq_123", %{limit: 10})

      assert response.status == 200
    end

    test "returns error on invalid offer request", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/offers", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid offer request ID"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.Offers.list(config, "orq_invalid")

      assert error.status == 400
    end
  end

  describe "get_priced/3" do
    test "sends POST to /air/offers/{id}/actions/price", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/offers/off_123/actions/price", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert length(data["intended_payment_methods"]) == 1
        assert hd(data["intended_payment_methods"])["type"] == "balance"

        conn
        |> Plug.Conn.resp(200, offer_priced_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Offers.get_priced(config, "off_123", %{
          intended_payment_methods: [%{type: "balance"}],
          intended_services: []
        })

      assert response.status == 200
      assert %Travel.Flights.Types.OfferPriced{} = response.data
      assert response.data.id == "off_123"
      assert length(response.data.intended_payment_methods) == 1
    end

    test "returns error on pricing failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/offers/off_expired/actions/price", fn conn ->
        conn
        |> Plug.Conn.resp(422, error_response("Offer has expired"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Offers.get_priced(config, "off_expired", %{
          intended_payment_methods: [%{type: "balance"}],
          intended_services: []
        })

      assert error.status == 422
    end
  end

  defp offer_response do
    ~s({
      "data": {
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
      }
    })
  end

  defp offers_list_response do
    ~s({"data": [
      {"id": "off_1", "owner": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "total_amount": "500.00", "total_currency": "GBP", "base_amount": "400.00", "base_currency": "GBP", "tax_amount": "100.00", "tax_currency": "GBP", "expires_at": "2025-04-25T11:00:00Z", "slices": [{"id": "sli_1", "origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "duration": "PT8H", "fare_brand_name": "Economy", "segments": [{"id": "seg_1", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departing_at": "2025-06-01T10:00:00Z", "arriving_at": "2025-06-01T18:00:00Z", "duration": "PT8H", "marketing_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "operating_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "marketing_carrier_flight_number": "123", "passengers": [{"passenger_id": "pas_1", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T123", "baggages": []}], "stops": []}], "conditions": {}, "ngs_shelf": 1}], "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}], "conditions": {}, "available_services": [], "private_fares": [], "payment_requirements": {"payment_required_by": null, "price_guarantee_expires_at": null, "requires_instant_payment": true}, "partial": false, "supported_loyalty_programmes": [], "supported_passenger_identity_document_types": [], "total_emissions_kg": "200.0", "live_mode": false, "created_at": "2025-04-25T10:00:00Z", "updated_at": null},
      {"id": "off_2", "owner": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "total_amount": "550.00", "total_currency": "GBP", "base_amount": "450.00", "base_currency": "GBP", "tax_amount": "100.00", "tax_currency": "GBP", "expires_at": "2025-04-25T11:00:00Z", "slices": [{"id": "sli_2", "origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "duration": "PT8H30M", "fare_brand_name": "Economy", "segments": [{"id": "seg_2", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departing_at": "2025-06-01T12:00:00Z", "arriving_at": "2025-06-01T20:30:00Z", "duration": "PT8H30M", "marketing_carrier": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "operating_carrier": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "marketing_carrier_flight_number": "456", "passengers": [{"passenger_id": "pas_1", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T456", "baggages": []}], "stops": []}], "conditions": {}, "ngs_shelf": 2}], "passengers": [{"id": "pas_1", "age": null, "type": "adult", "given_name": null, "family_name": null}], "conditions": {}, "available_services": [], "private_fares": [], "payment_requirements": {"payment_required_by": null, "price_guarantee_expires_at": null, "requires_instant_payment": true}, "partial": false, "supported_loyalty_programmes": [], "supported_passenger_identity_document_types": [], "total_emissions_kg": "210.0", "live_mode": false, "created_at": "2025-04-25T10:00:00Z", "updated_at": null}
    ]})
  end

  defp offer_priced_response do
    ~s({
      "data": {
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
        "updated_at": null,
        "intended_payment_methods": [{"type": "balance"}],
        "intended_services": []
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
