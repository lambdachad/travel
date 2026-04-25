defmodule Travel.Flights.OrdersTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/orders with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/orders", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert data["selected_offers"] == ["off_123"]
        assert length(data["passengers"]) == 1
        assert data["type"] == "instant"

        conn
        |> Plug.Conn.resp(200, order_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Orders.create(config, %{
          selected_offers: ["off_123"],
          passengers: [
            %{
              given_name: "John",
              family_name: "Smith",
              born_on: "1990-01-01",
              gender: "m",
              title: "mr",
              email: "john@example.com",
              phone_number: "+442080160509"
            }
          ],
          type: "instant"
        })

      assert response.status == 200
      assert %Travel.Flights.Types.Order{} = response.data
      assert response.data.id == "ord_123"
      assert response.data.booking_reference == "ABCDEF"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/orders", fn conn ->
        conn
        |> Plug.Conn.resp(422, error_response("Offer has expired"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Orders.create(config, %{
          selected_offers: ["off_expired"],
          passengers: [
            %{
              given_name: "John",
              family_name: "Smith",
              born_on: "1990-01-01",
              gender: "m",
              title: "mr",
              email: "john@example.com",
              phone_number: "+442080160509"
            }
          ],
          type: "instant"
        })

      assert error.status == 422
    end
  end

  describe "get/2" do
    test "sends GET to /air/orders/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders/ord_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, order_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Orders.get(config, "ord_123")

      assert response.status == 200
      assert %Travel.Flights.Types.Order{} = response.data
      assert response.data.id == "ord_123"
      assert response.data.booking_reference == "ABCDEF"
      assert response.data.total_amount == "500.00"
      assert length(response.data.passengers) == 1
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders/ord_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.Orders.get(config, "ord_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /air/orders", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders", fn conn ->
        conn
        |> Plug.Conn.resp(200, orders_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Orders.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.Order{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, orders_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Orders.list(config, %{limit: 10})

      assert response.status == 200
    end

    test "filters by awaiting_payment", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders", fn conn ->
        assert conn.query_string =~ "awaiting_payment=true"

        conn
        |> Plug.Conn.resp(200, ~s({"data": []}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Orders.list(config, %{awaiting_payment: true})

      assert response.status == 200
      assert response.data == []
    end
  end

  describe "update/3" do
    test "sends PATCH to /air/orders/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/orders/ord_123", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert data["metadata"]["payment_intent_id"] == "pit_123"

        conn
        |> Plug.Conn.resp(200, order_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Orders.update(config, "ord_123", %{
          metadata: %{"payment_intent_id" => "pit_123"}
        })

      assert response.status == 200
      assert %Travel.Flights.Types.Order{} = response.data
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/orders/ord_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Orders.update(config, "ord_invalid", %{
          metadata: %{"key" => "value"}
        })

      assert error.status == 404
    end
  end

  describe "get_available_services/2" do
    test "sends GET to /air/orders/{id}/available_services", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders/ord_123/available_services", fn conn ->
        conn
        |> Plug.Conn.resp(200, available_services_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.Orders.get_available_services(config, "ord_123")

      assert response.status == 200
      assert length(response.data) == 1
      assert %Travel.Flights.Types.OfferAvailableService{} = hd(response.data)
      assert hd(response.data).type == :baggage
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/orders/ord_invalid/available_services", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Order not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.Orders.get_available_services(config, "ord_invalid")

      assert error.status == 404
    end
  end

  describe "add_services/3" do
    test "sends POST to /air/orders/{id}/services", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/orders/ord_123/services", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert length(data["add_services"]) == 1
        assert hd(data["add_services"])["id"] == "asr_123"
        assert hd(data["add_services"])["quantity"] == 1

        conn
        |> Plug.Conn.resp(200, order_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.Orders.add_services(config, "ord_123", %{
          payment: %{type: "balance", amount: "30.00", currency: "GBP"},
          add_services: [%{id: "asr_123", quantity: 1}]
        })

      assert response.status == 200
      assert %Travel.Flights.Types.Order{} = response.data
    end

    test "returns error on invalid service", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/orders/ord_123/services", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Service not available"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.Orders.add_services(config, "ord_123", %{
          payment: %{type: "balance", amount: "30.00", currency: "GBP"},
          add_services: [%{id: "asr_invalid", quantity: 1}]
        })

      assert error.status == 400
    end
  end

  defp order_response do
    ~s({
      "data": {
        "id": "ord_123",
        "booking_reference": "ABCDEF",
        "owner": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"},
        "total_amount": "500.00",
        "total_currency": "GBP",
        "base_amount": "400.00",
        "base_currency": "GBP",
        "tax_amount": "100.00",
        "tax_currency": "GBP",
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
            "passengers": [{"passenger_id": "pas_123", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T123", "baggages": []}],
            "stops": []
          }],
          "conditions": {},
          "ngs_shelf": 1
        }],
        "services": [],
        "passengers": [{
          "id": "pas_123",
          "born_on": "1990-01-01",
          "family_name": "Smith",
          "given_name": "John",
          "gender": "m",
          "title": "mr",
          "type": "adult",
          "email": "john@example.com",
          "phone_number": "+447700900000"
        }],
        "payment_status": {"awaiting_payment": false, "payment_required_by": null, "price_guarantee_expires_at": null, "paid_at": "2025-04-25T10:00:00Z"},
        "live_mode": false,
        "documents": [],
        "created_at": "2025-04-25T10:00:00Z",
        "cancelled_at": null,
        "conditions": {},
        "metadata": null,
        "airline_initiated_changes": [],
        "available_actions": [],
        "synced_at": null,
        "cancellation": null
      }
    })
  end

  defp orders_list_response do
    ~s({"data": [
      {"id": "ord_1", "booking_reference": "ABC001", "owner": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "total_amount": "500.00", "total_currency": "GBP", "base_amount": "400.00", "base_currency": "GBP", "tax_amount": "100.00", "tax_currency": "GBP", "slices": [{"id": "sli_1", "origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "duration": "PT8H", "fare_brand_name": "Economy", "segments": [{"id": "seg_1", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departing_at": "2025-06-01T10:00:00Z", "arriving_at": "2025-06-01T18:00:00Z", "duration": "PT8H", "marketing_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "operating_carrier": {"id": "aln_123", "name": "British Airways", "iata_code": "BA"}, "marketing_carrier_flight_number": "123", "passengers": [{"passenger_id": "pas_1", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T123", "baggages": []}], "stops": []}], "conditions": {}, "ngs_shelf": 1}], "services": [], "passengers": [{"id": "pas_1", "born_on": "1990-01-01", "family_name": "Smith", "given_name": "John", "gender": "m", "title": "mr", "type": "adult", "email": "john@example.com", "phone_number": "+447700900000"}], "payment_status": {"awaiting_payment": false, "payment_required_by": null, "price_guarantee_expires_at": null, "paid_at": "2025-04-25T10:00:00Z"}, "live_mode": false, "documents": [], "created_at": "2025-04-25T10:00:00Z", "cancelled_at": null, "conditions": {}, "metadata": null, "airline_initiated_changes": [], "available_actions": [], "synced_at": null, "cancellation": null},
      {"id": "ord_2", "booking_reference": "ABC002", "owner": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "total_amount": "600.00", "total_currency": "GBP", "base_amount": "500.00", "base_currency": "GBP", "tax_amount": "100.00", "tax_currency": "GBP", "slices": [{"id": "sli_2", "origin_type": "airport", "destination_type": "airport", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "duration": "PT8H30M", "fare_brand_name": "Economy", "segments": [{"id": "seg_2", "origin": {"type": "airport", "id": "apl_LHR", "name": "London Heathrow", "iata_code": "LHR", "iata_country_code": "GB"}, "destination": {"type": "airport", "id": "apl_JFK", "name": "New York JFK", "iata_code": "JFK", "iata_country_code": "US"}, "departing_at": "2025-06-01T12:00:00Z", "arriving_at": "2025-06-01T20:30:00Z", "duration": "PT8H30M", "marketing_carrier": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "operating_carrier": {"id": "aln_456", "name": "American Airlines", "iata_code": "AA"}, "marketing_carrier_flight_number": "456", "passengers": [{"passenger_id": "pas_2", "cabin_class": "economy", "cabin_class_marketing_name": "Economy", "fare_basis_code": "T456", "baggages": []}], "stops": []}], "conditions": {}, "ngs_shelf": 2}], "services": [], "passengers": [{"id": "pas_2", "born_on": "1985-05-15", "family_name": "Doe", "given_name": "Jane", "gender": "f", "title": "ms", "type": "adult", "email": "jane@example.com", "phone_number": "+447700900001"}], "payment_status": {"awaiting_payment": true, "payment_required_by": "2025-04-26T10:00:00Z", "price_guarantee_expires_at": null, "paid_at": null}, "live_mode": false, "documents": [], "created_at": "2025-04-25T11:00:00Z", "cancelled_at": null, "conditions": {}, "metadata": null, "airline_initiated_changes": [], "available_actions": [], "synced_at": null, "cancellation": null}
    ]})
  end

  defp available_services_response do
    ~s({"data": [{
      "id": "asr_123",
      "type": "baggage",
      "passenger_ids": ["pas_123"],
      "segment_ids": ["seg_123"],
      "total_amount": "30.00",
      "total_currency": "GBP",
      "metadata": {"segment_id": "seg_123", "passenger_id": "pas_123", "max_weight_kg": 23}
    }]})
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
