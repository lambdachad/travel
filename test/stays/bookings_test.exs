defmodule Travel.Stays.BookingsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /stays/bookings with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/bookings", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]
        assert data["quote_id"] == "quo_123"
        assert length(data["guests"]) == 1
        assert data["email"] == "john@example.com"

        conn
        |> Plug.Conn.resp(200, booking_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Bookings.create(config, %{
          quote_id: "quo_123",
          guests: [%{given_name: "John", family_name: "Smith"}],
          email: "john@example.com",
          phone_number: "+447700900000"
        })

      assert response.status == 200
      assert %Travel.Stays.Types.StaysBooking{} = response.data
      assert response.data.id == "bok_123"
      assert response.data.status == :confirmed
    end

    test "handles 202 accepted response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/bookings", fn conn ->
        conn
        |> Plug.Conn.resp(202, ~s({"data": {"message": "Booking is being processed"}}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Stays.Bookings.create(config, %{
          quote_id: "quo_123",
          guests: [%{given_name: "John", family_name: "Smith"}],
          email: "john@example.com",
          phone_number: "+447700900000"
        })

      assert response.status == 202
    end
  end

  describe "get/2" do
    test "sends GET to /stays/bookings/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings/bok_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, booking_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Bookings.get(config, "bok_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysBooking{} = response.data
      assert response.data.reference == "REF123"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings/bok_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Booking not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.Bookings.get(config, "bok_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /stays/bookings", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings", fn conn ->
        conn
        |> Plug.Conn.resp(200, bookings_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Bookings.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Stays.Types.StaysBooking{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, bookings_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Bookings.list(config, %{limit: 10})

      assert response.status == 200
    end

    test "filters by user_id", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings", fn conn ->
        assert conn.query_string =~ "user_id=icu_123"

        conn
        |> Plug.Conn.resp(200, ~s({"data": []}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Bookings.list(config, %{user_id: "icu_123"})

      assert response.status == 200
      assert response.data == []
    end
  end

  describe "stream/2" do
    test "streams all pages of bookings", %{bypass: bypass} do
      call_count = :atomics.new(1, [])

      Bypass.expect(bypass, fn conn ->
        cond do
          conn.request_path == "/stays/bookings" and conn.query_string == "" ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "bok_1", "email": "a@b.com", "phone_number": "+447700900000", "accommodation": {"id": "acc_1", "name": "H1", "email": "h@h.com", "phone_number": "123", "location": {"address": {"city_name": "C", "country_code": "GB", "line_one": "1", "postal_code": "1"}, "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}}, "chain": null, "brand": null, "amenities": [], "rooms": [], "photos": [], "ratings": [], "rating": null, "review_count": null, "review_score": null, "supported_loyalty_programme": null, "check_in_information": null, "key_collection": null}, "check_in_date": "2025-06-01", "check_out_date": "2025-06-05", "reference": "R1", "status": "confirmed", "confirmed_at": "2025-04-25T10:00:00Z", "cancelled_at": null, "guests": [{"given_name": "J", "family_name": "S"}], "supported_loyalty_programme": null, "loyalty_programme_account_number": null, "rooms": 1, "metadata": null, "key_collection": null, "estimated_commission_amount": null, "estimated_commission_currency": null}], "meta": {"limit": 1, "after": "cursor_2"}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/stays/bookings" and
              String.contains?(conn.query_string, "after=cursor_2") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "bok_2", "email": "a@b.com", "phone_number": "+447700900000", "accommodation": {"id": "acc_2", "name": "H2", "email": "h@h.com", "phone_number": "123", "location": {"address": {"city_name": "C", "country_code": "GB", "line_one": "1", "postal_code": "1"}, "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}}, "chain": null, "brand": null, "amenities": [], "rooms": [], "photos": [], "ratings": [], "rating": null, "review_count": null, "review_score": null, "supported_loyalty_programme": null, "check_in_information": null, "key_collection": null}, "check_in_date": "2025-06-01", "check_out_date": "2025-06-05", "reference": "R2", "status": "confirmed", "confirmed_at": "2025-04-25T10:00:00Z", "cancelled_at": null, "guests": [{"given_name": "J", "family_name": "S"}], "supported_loyalty_programme": null, "loyalty_programme_account_number": null, "rooms": 1, "metadata": null, "key_collection": null, "estimated_commission_amount": null, "estimated_commission_currency": null}], "meta": {"limit": 1, "after": null}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      config = travel_config(bypass.port)

      responses =
        Travel.Stays.Bookings.stream(config)
        |> Enum.to_list()

      assert length(responses) == 2
      assert :atomics.get(call_count, 1) == 2
    end
  end

  describe "cancel/2" do
    test "sends POST to /stays/bookings/{id}/actions/cancel", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/bookings/bok_123/actions/cancel", fn conn ->
        conn
        |> Plug.Conn.resp(200, cancelled_booking_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Bookings.cancel(config, "bok_123")

      assert response.status == 200
      assert response.data.status == :cancelled
    end
  end

  defp booking_response do
    ~s({
      "data": {
        "id": "bok_123",
        "email": "john@example.com",
        "phone_number": "+447700900000",
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
        },
        "check_in_date": "2025-06-01",
        "check_out_date": "2025-06-05",
        "reference": "REF123",
        "status": "confirmed",
        "confirmed_at": "2025-04-25T10:00:00Z",
        "cancelled_at": null,
        "guests": [{"given_name": "John", "family_name": "Smith"}],
        "supported_loyalty_programme": null,
        "loyalty_programme_account_number": null,
        "rooms": 1,
        "metadata": null,
        "key_collection": null,
        "estimated_commission_amount": null,
        "estimated_commission_currency": null
      }
    })
  end

  defp cancelled_booking_response do
    ~s({
      "data": {
        "id": "bok_123",
        "email": "john@example.com",
        "phone_number": "+447700900000",
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
        },
        "check_in_date": "2025-06-01",
        "check_out_date": "2025-06-05",
        "reference": "REF123",
        "status": "cancelled",
        "confirmed_at": "2025-04-25T10:00:00Z",
        "cancelled_at": "2025-04-26T10:00:00Z",
        "guests": [{"given_name": "John", "family_name": "Smith"}],
        "supported_loyalty_programme": null,
        "loyalty_programme_account_number": null,
        "rooms": 1,
        "metadata": null,
        "key_collection": null,
        "estimated_commission_amount": null,
        "estimated_commission_currency": null
      }
    })
  end

  defp bookings_list_response do
    ~s({"data": [
      {"id": "bok_1", "email": "a@b.com", "phone_number": "+447700900000", "accommodation": {"id": "acc_1", "name": "H1", "email": "h@h.com", "phone_number": "123", "location": {"address": {"city_name": "C", "country_code": "GB", "line_one": "1", "postal_code": "1"}, "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}}, "chain": null, "brand": null, "amenities": [], "rooms": [], "photos": [], "ratings": [], "rating": null, "review_count": null, "review_score": null, "supported_loyalty_programme": null, "check_in_information": null, "key_collection": null}, "check_in_date": "2025-06-01", "check_out_date": "2025-06-05", "reference": "R1", "status": "confirmed", "confirmed_at": "2025-04-25T10:00:00Z", "cancelled_at": null, "guests": [{"given_name": "J", "family_name": "S"}], "supported_loyalty_programme": null, "loyalty_programme_account_number": null, "rooms": 1, "metadata": null, "key_collection": null, "estimated_commission_amount": null, "estimated_commission_currency": null},
      {"id": "bok_2", "email": "a@b.com", "phone_number": "+447700900000", "accommodation": {"id": "acc_2", "name": "H2", "email": "h@h.com", "phone_number": "123", "location": {"address": {"city_name": "C", "country_code": "GB", "line_one": "1", "postal_code": "1"}, "geographic_coordinates": {"latitude": 51.5, "longitude": -0.1}}, "chain": null, "brand": null, "amenities": [], "rooms": [], "photos": [], "ratings": [], "rating": null, "review_count": null, "review_score": null, "supported_loyalty_programme": null, "check_in_information": null, "key_collection": null}, "check_in_date": "2025-06-01", "check_out_date": "2025-06-05", "reference": "R2", "status": "confirmed", "confirmed_at": "2025-04-25T10:00:00Z", "cancelled_at": null, "guests": [{"given_name": "J", "family_name": "S"}], "supported_loyalty_programme": null, "loyalty_programme_account_number": null, "rooms": 1, "metadata": null, "key_collection": null, "estimated_commission_amount": null, "estimated_commission_currency": null}
    ]})
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
