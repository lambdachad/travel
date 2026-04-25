defmodule Travel.Flights.OrderChangeOffersTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "get/2" do
    test "sends GET to /air/order_change_offers/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_offers/oco_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, change_offer_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChangeOffers.get(config, "oco_123")

      assert response.status == 200
      assert %Travel.Flights.Types.OrderChangeOffer{} = response.data
      assert response.data.id == "oco_123"
      assert response.data.change_total_amount == "50.00"
      assert response.data.change_total_currency == "GBP"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_offers/oco_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Change offer not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.OrderChangeOffers.get(config, "oco_invalid")

      assert error.status == 404
    end
  end

  describe "list/2" do
    test "sends GET to /air/order_change_offers", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_offers", fn conn ->
        conn
        |> Plug.Conn.resp(200, change_offers_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChangeOffers.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Flights.Types.OrderChangeOffer{} = hd(response.data)
    end

    test "passes pagination params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/order_change_offers", fn conn ->
        assert conn.query_string =~ "limit=10"

        conn
        |> Plug.Conn.resp(200, change_offers_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.OrderChangeOffers.list(config, %{limit: 10})

      assert response.status == 200
    end
  end

  describe "stream/2" do
    test "streams all pages of change offers", %{bypass: bypass} do
      call_count = :atomics.new(1, [])

      Bypass.expect(bypass, fn conn ->
        cond do
          conn.request_path == "/air/order_change_offers" and conn.query_string == "" ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "oco_1", "order_id": "ord_1", "change_total_amount": "50.00", "change_total_currency": "GBP", "new_total_amount": "200.00", "new_total_currency": "GBP", "penalty_total_amount": "25.00", "penalty_total_currency": "GBP", "refund_to": "original_form_of_payment", "slices": {"add": [], "remove": []}, "expires_at": "2025-05-01T12:00:00Z", "created_at": "2025-04-25T10:00:00Z", "updated_at": null, "order_change_id": null}], "meta": {"limit": 1, "after": "cursor_2"}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/air/order_change_offers" and
              String.contains?(conn.query_string, "after=cursor_2") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({"data": [{"id": "oco_2", "order_id": "ord_2", "change_total_amount": "75.00", "change_total_currency": "GBP", "new_total_amount": "250.00", "new_total_currency": "GBP", "penalty_total_amount": "30.00", "penalty_total_currency": "GBP", "refund_to": "original_form_of_payment", "slices": {"add": [], "remove": []}, "expires_at": "2025-05-02T12:00:00Z", "created_at": "2025-04-25T11:00:00Z", "updated_at": null, "order_change_id": null}], "meta": {"limit": 1, "after": null}})
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      config = travel_config(bypass.port)

      responses =
        Travel.Flights.OrderChangeOffers.stream(config)
        |> Enum.to_list()

      assert length(responses) == 2
      assert :atomics.get(call_count, 1) == 2
    end
  end

  defp change_offer_response do
    ~s({"data": {
      "id": "oco_123",
      "order_id": "ord_123",
      "change_total_amount": "50.00",
      "change_total_currency": "GBP",
      "new_total_amount": "200.00",
      "new_total_currency": "GBP",
      "penalty_total_amount": "25.00",
      "penalty_total_currency": "GBP",
      "refund_to": "original_form_of_payment",
      "slices": {"add": [], "remove": []},
      "expires_at": "2025-05-01T12:00:00Z",
      "created_at": "2025-04-25T10:00:00Z",
      "updated_at": null,
      "order_change_id": null
    }})
  end

  defp change_offers_list_response do
    ~s({"data": [
      {"id": "oco_1", "order_id": "ord_1", "change_total_amount": "50.00", "change_total_currency": "GBP", "new_total_amount": "200.00", "new_total_currency": "GBP", "penalty_total_amount": "25.00", "penalty_total_currency": "GBP", "refund_to": "original_form_of_payment", "slices": {"add": [], "remove": []}, "expires_at": "2025-05-01T12:00:00Z", "created_at": "2025-04-25T10:00:00Z", "updated_at": null, "order_change_id": null},
      {"id": "oco_2", "order_id": "ord_2", "change_total_amount": "75.00", "change_total_currency": "GBP", "new_total_amount": "250.00", "new_total_currency": "GBP", "penalty_total_amount": "30.00", "penalty_total_currency": "GBP", "refund_to": "original_form_of_payment", "slices": {"add": [], "remove": []}, "expires_at": "2025-05-02T12:00:00Z", "created_at": "2025-04-25T11:00:00Z", "updated_at": null, "order_change_id": null}
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
