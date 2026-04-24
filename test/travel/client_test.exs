defmodule Travel.ClientTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "request/5" do
    test "sends authenticated request with correct headers", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/search", fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer test_token"]
        assert Plug.Conn.get_req_header(conn, "duffel-version") == ["v2"]
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]

        conn
        |> Plug.Conn.resp(200, ~s({"data": {"id": "search_123"}}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Client.request(
          config,
          :post,
          "stays/search",
          %{check_in_date: "2025-06-01"}
        )

      assert response.data["id"] == "search_123"
      assert response.status == 200
    end

    test "wraps body in data key", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/stays/bookings", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert Map.has_key?(decoded, "data")
        assert decoded["data"]["quote_id"] == "quo_123"

        conn
        |> Plug.Conn.resp(200, ~s({"data": {"id": "bok_123"}}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Client.request(
          config,
          :post,
          "stays/bookings",
          %{quote_id: "quo_123"}
        )

      assert response.data["id"] == "bok_123"
    end

    test "handles query parameters", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings", fn conn ->
        assert conn.query_string =~ "limit=10"
        assert conn.query_string =~ "after=cursor_abc"

        conn
        |> Plug.Conn.resp(
          200,
          ~s({"data": [{"id": "bok_1"}], "meta": {"limit": 10, "after": null}})
        )
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Client.request(
          config,
          :get,
          "stays/bookings",
          nil,
          %{"limit" => 10, "after" => "cursor_abc"}
        )

      assert length(response.data) == 1
    end

    test "returns error on API error response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings/bok_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(
          404,
          ~s({
            "meta": {"request_id": "req_123"},
            "errors": [{
              "code": "not_found",
              "message": "Booking not found",
              "title": "Not Found",
              "type": "invalid_request",
              "documentation_url": "https://duffel.com/docs/api/errors"
            }]
          })
        )
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:error, error} =
        Travel.Client.request(config, :get, "stays/bookings/bok_invalid")

      assert error.status == 404
      assert error.code == "not_found"
      assert error.message == "Booking not found"
      assert error.request_id == "req_123"
    end

    test "parses pagination metadata", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/bookings", fn conn ->
        conn
        |> Plug.Conn.resp(
          200,
          ~s({
            "data": [{"id": "bok_1"}, {"id": "bok_2"}],
            "meta": {"limit": 20, "before": null, "after": "cursor_xyz"}
          })
        )
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} = Travel.Client.request(config, :get, "stays/bookings")

      assert response.meta.limit == 20
      assert response.meta.before == nil
      assert response.meta.after == "cursor_xyz"
      assert length(response.data) == 2
    end

    test "handles GET without body", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/brands", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s({"data": [{"id": "brand_1", "name": "Test"}]}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} = Travel.Client.request(config, :get, "stays/brands")
      assert length(response.data) == 1
    end

    test "handles PATCH request", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PATCH", "/air/orders/ord_123", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        decoded = Jason.decode!(body)
        assert decoded["data"]["metadata"]["key"] == "value"

        conn
        |> Plug.Conn.resp(200, ~s({"data": {"id": "ord_123"}}))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)

      {:ok, response} =
        Travel.Client.request(
          config,
          :patch,
          "air/orders/ord_123",
          %{metadata: %{"key" => "value"}}
        )

      assert response.data["id"] == "ord_123"
    end
  end

  describe "stream/3" do
    test "streams all pages of results", %{bypass: bypass} do
      call_count = :atomics.new(1, [])

      Bypass.expect(bypass, fn conn ->
        cond do
          conn.request_path == "/stays/bookings" and conn.query_string == "" ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({
                "data": [{"id": "bok_1"}],
                "meta": {"limit": 1, "after": "cursor_2"}
              })
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/stays/bookings" and
              String.contains?(conn.query_string, "after=cursor_2") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({
                "data": [{"id": "bok_2"}],
                "meta": {"limit": 1, "after": "cursor_3"}
              })
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")

          conn.request_path == "/stays/bookings" and
              String.contains?(conn.query_string, "after=cursor_3") ->
            :atomics.add(call_count, 1, 1)

            conn
            |> Plug.Conn.resp(
              200,
              ~s({
                "data": [{"id": "bok_3"}],
                "meta": {"limit": 1, "after": null}
              })
            )
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      config = travel_config(bypass.port)

      responses =
        Travel.Client.stream(config, "stays/bookings")
        |> Enum.to_list()

      assert length(responses) == 3
      assert :atomics.get(call_count, 1) == 3
    end
  end

  defp travel_config(port) do
    Travel.new(
      access_token: "test_token",
      base_url: "http://localhost:#{port}"
    )
  end
end
