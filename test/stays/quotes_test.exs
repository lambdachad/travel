defmodule Travel.Stays.QuotesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /stays/quotes with rate_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/quotes", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["rate_id"] == "rate_123"

        conn
        |> Plug.Conn.resp(200, quote_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Quotes.create(config, "rate_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysQuote{} = response.data
      assert response.data.id == "quo_123"
      assert response.data.total_amount == "200.00"
    end
  end

  describe "get/2" do
    test "sends GET to /stays/quotes/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/quotes/quo_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, quote_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Quotes.get(config, "quo_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysQuote{} = response.data
      assert response.data.check_in_date == "2025-06-01"
      assert response.data.rooms == 1
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/quotes/quo_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Quote not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.Quotes.get(config, "quo_invalid")

      assert error.status == 404
    end
  end

  defp quote_response do
    ~s({
      "data": {
        "id": "quo_123",
        "check_in_date": "2025-06-01",
        "check_out_date": "2025-06-05",
        "total_amount": "200.00",
        "total_currency": "GBP",
        "base_amount": "170.00",
        "base_currency": "GBP",
        "fee_amount": "15.00",
        "fee_currency": "GBP",
        "tax_amount": "15.00",
        "tax_currency": "GBP",
        "due_at_accommodation_amount": null,
        "due_at_accommodation_currency": "GBP",
        "deposit_amount": "50.00",
        "deposit_currency": "GBP",
        "supported_loyalty_programme": null,
        "rooms": 1,
        "guests": [{"type": "adult"}],
        "accommodation": {
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
        }
      }
    })
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
