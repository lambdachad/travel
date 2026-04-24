defmodule Travel.Stays.SearchTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "search/2" do
    test "sends POST to /stays/search", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/search", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)

        assert decoded["data"]["check_in_date"] == "2025-06-01"
        assert decoded["data"]["check_out_date"] == "2025-06-05"
        assert decoded["data"]["rooms"] == 1

        conn
        |> Plug.Conn.resp(200, search_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Search.search(config, %{
          location: %{
            geographic_coordinates: %{latitude: 51.5, longitude: -0.1},
            radius: 5
          },
          check_in_date: "2025-06-01",
          check_out_date: "2025-06-05",
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      assert response.status == 200
      assert length(response.data.results) == 1
    end

    test "returns parsed StaysSearchResponse", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/search", fn conn ->
        conn
        |> Plug.Conn.resp(200, search_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Search.search(config, %{
          location: %{
            geographic_coordinates: %{latitude: 51.5, longitude: -0.1},
            radius: 5
          },
          check_in_date: "2025-06-01",
          check_out_date: "2025-06-05",
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      assert %Travel.Stays.Types.StaysSearchResponse{} = response.data
      assert length(response.data.results) == 1

      result = hd(response.data.results)
      assert %Travel.Stays.Types.StaysSearchResult{} = result
      assert result.id == "ser_123"
      assert result.check_in_date == "2025-06-01"
      assert result.cheapest_rate_total_amount == "150.00"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/search", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid search parameters"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Stays.Search.search(config, %{
          location: %{geographic_coordinates: %{}, radius: 0},
          check_in_date: "invalid",
          check_out_date: "invalid",
          rooms: 0,
          guests: []
        })

      assert error.status == 400
    end
  end

  defp search_response do
    ~s({
      "data": {
        "results": [{
          "id": "ser_123",
          "check_in_date": "2025-06-01",
          "check_out_date": "2025-06-05",
          "rooms": 1,
          "guests": [{"type": "adult"}],
          "cheapest_rate_total_amount": "150.00",
          "cheapest_rate_currency": "GBP",
          "cheapest_rate_base_amount": "125.00",
          "cheapest_rate_base_currency": "GBP",
          "cheapest_rate_public_amount": "150.00",
          "cheapest_rate_public_currency": "GBP",
          "cheapest_rate_due_at_accommodation_amount": null,
          "cheapest_rate_due_at_accommodation_currency": "GBP",
          "expires_at": "2025-05-01T12:00:00Z",
          "accommodation": {
            "id": "acc_123",
            "name": "Test Hotel",
            "description": "A nice hotel",
            "email": "hotel@test.com",
            "phone_number": "+447700900000",
            "location": {
              "address": {
                "city_name": "London",
                "country_code": "GB",
                "line_one": "123 Test St",
                "postal_code": "W1A 1AA"
              },
              "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}
            },
            "chain": {"name": "Test Chain"},
            "brand": {"id": "brd_1", "name": "Test Brand"},
            "amenities": [{"type": "wifi", "description": "Free WiFi"}],
            "rooms": [{
              "name": "Standard Room",
              "beds": [{"type": "double", "count": 1}],
              "photos": [{"url": "https://example.com/room.jpg"}],
              "rates": [{
                "id": "rate_1",
                "base_amount": "100.00",
                "base_currency": "GBP",
                "total_amount": "150.00",
                "total_currency": "GBP",
                "tax_amount": "25.00",
                "tax_currency": "GBP",
                "fee_amount": "10.00",
                "fee_currency": "GBP",
                "due_at_accommodation_amount": null,
                "due_at_accommodation_currency": "GBP",
                "board_type": "room_only",
                "payment_type": "pay_now",
                "available_payment_methods": ["balance", "card"],
                "conditions": [{"title": "Non-refundable", "description": "No refunds"}],
                "cancellation_timeline": [],
                "supported_loyalty_programme": null,
                "loyalty_programme_required": false,
                "source": "bookingcom",
                "expires_at": "2025-05-01T12:00:00Z",
                "code": null,
                "description": null,
                "name": "Best Rate",
                "estimated_commission_amount": "15.00",
                "estimated_commission_currency": "GBP",
                "quantity_available": 3
              }]
            }],
            "photos": [{"url": "https://example.com/hotel.jpg"}],
            "ratings": [{"source": "aaa", "value": 4}],
            "rating": 4,
            "review_count": 100,
            "review_score": 8.5,
            "supported_loyalty_programme": null,
            "check_in_information": {
              "check_in_after_time": "15:00",
              "check_out_before_time": "11:00"
            },
            "key_collection": null
          }
        }],
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
