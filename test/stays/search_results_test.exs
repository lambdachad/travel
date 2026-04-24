defmodule Travel.Stays.SearchResultsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "fetch_all_rates/2" do
    test "sends POST to /stays/search_results/{id}/actions/fetch_all_rates", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/stays/search_results/ser_123/actions/fetch_all_rates",
        fn conn ->
          conn
          |> Plug.Conn.resp(200, search_result_response())
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.SearchResults.fetch_all_rates(config, "ser_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysSearchResult{} = response.data
      assert response.data.id == "ser_123"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/stays/search_results/ser_invalid/actions/fetch_all_rates",
        fn conn ->
          conn
          |> Plug.Conn.resp(404, error_response("Search result not found"))
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      )

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.SearchResults.fetch_all_rates(config, "ser_invalid")

      assert error.status == 404
    end
  end

  defp search_result_response do
    ~s({
      "data": {
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
