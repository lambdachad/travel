defmodule Travel.Stays.AccommodationTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "get/2" do
    test "sends GET to /stays/accommodation/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation/acc_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, accommodation_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Accommodation.get(config, "acc_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysAccommodation{} = response.data
      assert response.data.id == "acc_123"
      assert response.data.name == "Test Hotel"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation/acc_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Accommodation not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.Accommodation.get(config, "acc_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /stays/accommodation with params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation", fn conn ->
        assert conn.query_string =~ "latitude=51.5"
        assert conn.query_string =~ "longitude=-0.1"
        assert conn.query_string =~ "radius=5"

        conn
        |> Plug.Conn.resp(200, accommodations_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Accommodation.list(config, %{
          latitude: 51.5,
          longitude: -0.1,
          radius: 5
        })

      assert response.status == 200
      assert length(response.data) == 1
      assert %Travel.Stays.Types.StaysAccommodation{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, accommodations_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Accommodation.list(config, %{
          latitude: 51.5,
          longitude: -0.1,
          limit: 10
        })

      assert response.status == 200
    end
  end

  describe "suggestions/2" do
    test "sends POST to /stays/accommodation/suggestions with query", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/accommodation/suggestions", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["query"] == "Hilton London"

        conn
        |> Plug.Conn.resp(200, suggestions_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Accommodation.suggestions(config, "Hilton London")

      assert response.status == 200
      assert length(response.data) == 1
      assert %Travel.Stays.Types.StaysAccommodationSuggestion{} = hd(response.data)
    end

    test "sends POST with optional location filter", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/accommodation/suggestions", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["location"]["radius"] == 10

        conn
        |> Plug.Conn.resp(200, suggestions_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Accommodation.suggestions(config, "Hilton London", %{
          radius: 10,
          geographic_coordinates: %{latitude: 51.5, longitude: -0.1}
        })

      assert response.status == 200
    end
  end

  describe "reviews/3" do
    test "sends GET to /stays/accommodation/{id}/reviews", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation/acc_123/reviews", fn conn ->
        conn
        |> Plug.Conn.resp(200, reviews_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Accommodation.reviews(config, "acc_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysAccommodationReviewResponse{} = response.data
      assert length(response.data.reviews) == 2
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/accommodation/acc_123/reviews", fn conn ->
        assert conn.query_string =~ "limit=5"

        conn
        |> Plug.Conn.resp(200, reviews_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Accommodation.reviews(config, "acc_123", %{limit: 5})

      assert response.status == 200
    end
  end

  defp accommodation_response do
    ~s({
      "data": {
        "id": "acc_123",
        "name": "Test Hotel",
        "description": "A nice hotel",
        "email": "hotel@test.com",
        "phone_number": "+447700900000",
        "location": {
          "address": {"city_name": "London", "country_code": "GB", "line_one": "123 Test St", "postal_code": "W1A 1AA"},
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
            "fee_amount": null,
            "fee_currency": "GBP",
            "due_at_accommodation_amount": null,
            "due_at_accommodation_currency": "GBP",
            "board_type": "room_only",
            "payment_type": "pay_now",
            "available_payment_methods": ["balance", "card"],
            "conditions": [],
            "cancellation_timeline": [],
            "supported_loyalty_programme": null,
            "loyalty_programme_required": false,
            "source": "bookingcom",
            "expires_at": "2025-05-01T12:00:00Z",
            "code": null,
            "description": null,
            "name": "Best Rate",
            "estimated_commission_amount": null,
            "estimated_commission_currency": null,
            "quantity_available": 3
          }]
        }],
        "photos": [{"url": "https://example.com/hotel.jpg"}],
        "ratings": [{"source": "aaa", "value": 4}],
        "rating": 4,
        "review_count": 100,
        "review_score": 8.5,
        "supported_loyalty_programme": null,
        "check_in_information": {"check_in_after_time": "15:00", "check_out_before_time": "11:00"},
        "key_collection": null
      }
    })
  end

  defp accommodations_list_response do
    ~s({"data": [{
      "id": "acc_123",
      "name": "Test Hotel",
      "email": "hotel@test.com",
      "phone_number": "+447700900000",
      "location": {
        "address": {"city_name": "London", "country_code": "GB", "line_one": "123 Test St", "postal_code": "W1A 1AA"},
        "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}
      },
      "chain": null,
      "brand": null,
      "amenities": [],
      "rooms": [],
      "photos": [],
      "ratings": [],
      "rating": null,
      "review_count": null,
      "review_score": null,
      "supported_loyalty_programme": null,
      "check_in_information": null,
      "key_collection": null
    }]})
  end

  defp suggestions_response do
    ~s({"data": [{
      "accommodation_id": "acc_123",
      "accommodation_name": "Hilton London",
      "accommodation_location": {
        "address": {"city_name": "London", "country_code": "GB", "line_one": "1 Hilton St", "postal_code": "W1A 1AA"},
        "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}
      }
    }]})
  end

  defp reviews_response do
    ~s({"data": {"reviews": [
      {"created_at": "2025-01-15T10:00:00Z", "reviewer_name": "John", "score": 9.0, "text": "Great hotel!"},
      {"created_at": "2025-02-20T14:00:00Z", "reviewer_name": "Jane", "score": 7.5, "text": "Good stay"}
    ]}})
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
