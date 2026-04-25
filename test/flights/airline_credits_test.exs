defmodule Travel.Flights.AirlineCreditsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "create/2" do
    test "sends POST to /air/airline_credits with payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/airline_credits", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        data = decoded["data"]

        assert data["airline_iata_code"] == "BA"
        assert data["amount"] == "100.00"
        assert data["amount_currency"] == "GBP"
        assert data["code"] == "1234567890123"
        assert data["type"] == "eticket"
        assert data["issued_on"] == "2026-01-15"
        assert data["expires_at"] == "2027-01-15T00:00:00Z"

        conn
        |> Plug.Conn.resp(200, airline_credit_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Flights.AirlineCredits.create(config, %{
          airline_iata_code: "BA",
          amount: "100.00",
          amount_currency: "GBP",
          code: "1234567890123",
          type: "eticket",
          issued_on: "2026-01-15",
          expires_at: "2027-01-15T00:00:00Z"
        })

      assert response.status == 200
      assert %Travel.Flights.Types.AirlineCredit{} = response.data
      assert response.data.id == "acd_123"
      assert response.data.airline_iata_code == "BA"
      assert response.data.amount == "100.00"
      assert response.data.amount_currency == "GBP"
      assert response.data.type == :eticket
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/air/airline_credits", fn conn ->
        conn
        |> Plug.Conn.resp(422, error_response("Invalid airline credit"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Flights.AirlineCredits.create(config, %{
          airline_iata_code: "XX",
          amount: "100.00",
          amount_currency: "GBP",
          code: "invalid",
          type: "eticket",
          issued_on: "2026-01-15",
          expires_at: "2027-01-15T00:00:00Z"
        })

      assert error.status == 422
    end
  end

  describe "get/2" do
    test "sends GET to /air/airline_credits/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_credits/acd_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, airline_credit_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineCredits.get(config, "acd_123")

      assert response.status == 200
      assert %Travel.Flights.Types.AirlineCredit{} = response.data
      assert response.data.id == "acd_123"
      assert response.data.code == "1234567890123"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_credits/acd_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Airline credit not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.AirlineCredits.get(config, "acd_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /air/airline_credits", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_credits", fn conn ->
        conn
        |> Plug.Conn.resp(200, airline_credits_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineCredits.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.AirlineCredit{} = hd(response.data)
    end

    test "passes query params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/airline_credits", fn conn ->
        assert conn.query_string =~ "user_id=icu_123"

        conn
        |> Plug.Conn.resp(200, airline_credits_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.AirlineCredits.list(config, %{user_id: "icu_123"})

      assert response.status == 200
    end
  end

  defp airline_credit_response do
    ~s({
      "data": {
        "id": "acd_123",
        "airline_iata_code": "BA",
        "amount": "100.00",
        "amount_currency": "GBP",
        "code": "1234567890123",
        "type": "eticket",
        "issued_on": "2026-01-15",
        "expires_at": "2027-01-15T00:00:00Z",
        "passenger_id": null,
        "created_at": "2026-01-15T10:00:00Z",
        "live_mode": false
      }
    })
  end

  defp airline_credits_list_response do
    ~s({"data": [
      {"id": "acd_1", "airline_iata_code": "BA", "amount": "100.00", "amount_currency": "GBP", "code": "1234567890123", "type": "eticket", "issued_on": "2026-01-15", "expires_at": "2027-01-15T00:00:00Z", "passenger_id": null, "created_at": "2026-01-15T10:00:00Z", "live_mode": false},
      {"id": "acd_2", "airline_iata_code": "AA", "amount": "50.00", "amount_currency": "USD", "code": "9876543210987", "type": "mco", "issued_on": "2026-02-01", "expires_at": "2027-02-01T00:00:00Z", "passenger_id": "pas_123", "created_at": "2026-02-01T10:00:00Z", "live_mode": false}
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
