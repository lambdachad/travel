defmodule Travel.Flights.SeatMapsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "get/2" do
    test "sends GET to /air/seat_maps with offer_id param", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/seat_maps", fn conn ->
        assert conn.query_string =~ "offer_id=off_123"

        conn
        |> Plug.Conn.resp(200, seat_maps_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.SeatMaps.get(config, %{offer_id: "off_123"})

      assert response.status == 200
      assert %Travel.Flights.Types.SeatMap{} = hd(response.data)
      assert hd(response.data).id == "stm_123"
      assert hd(response.data).slice_id == "sli_123"
      assert hd(response.data).segment_id == "seg_123"
    end

    test "returns parsed seat maps with cabin data", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/seat_maps", fn conn ->
        conn
        |> Plug.Conn.resp(200, seat_maps_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Flights.SeatMaps.get(config, %{offer_id: "off_123"})

      seat_map = hd(response.data)
      assert length(seat_map.cabins) == 1
      cabin = hd(seat_map.cabins)
      assert cabin.cabin_class == :economy
      assert cabin.deck == "main"
      assert length(cabin.rows) == 1
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/air/seat_maps", fn conn ->
        conn
        |> Plug.Conn.resp(400, error_response("Invalid offer ID"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Flights.SeatMaps.get(config, %{offer_id: "off_invalid"})

      assert error.status == 400
    end
  end

  defp seat_maps_response do
    ~s({"data": [{
      "id": "stm_123",
      "slice_id": "sli_123",
      "segment_id": "seg_123",
      "cabins": [{
        "deck": "main",
        "cabin_class": "economy",
        "wings": [{"rows": [1, 2, 3]}],
        "aisles": [],
        "rows": [{
          "sections": [{
            "elements": [{
              "type": "seat",
              "designator": "1A",
              "name": "Window",
              "disclosures": [],
              "available_services": [{"id": "ase_123", "total_amount": "25.00", "total_currency": "GBP"}]
            }]
          }]
        }]
      }]
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
