defmodule Travel.Stays.BrandsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "list/1" do
    test "sends GET to /stays/brands", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/brands", fn conn ->
        conn
        |> Plug.Conn.resp(200, brands_list_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Brands.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Stays.Types.StaysAccommodationBrand{} = hd(response.data)
      assert hd(response.data).name == "Hilton"
    end
  end

  describe "get/2" do
    test "sends GET to /stays/brands/{id}", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/brands/brd_123", fn conn ->
        conn
        |> Plug.Conn.resp(200, brand_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.Brands.get(config, "brd_123")

      assert response.status == 200
      assert %Travel.Stays.Types.StaysAccommodationBrand{} = response.data
      assert response.data.id == "brd_123"
      assert response.data.name == "Hilton"
    end

    test "returns error on not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/brands/brd_invalid", fn conn ->
        conn
        |> Plug.Conn.resp(404, error_response("Brand not found"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.Brands.get(config, "brd_invalid")

      assert error.status == 404
    end
  end

  defp brands_list_response do
    ~s({"data": [
      {"id": "brd_123", "name": "Hilton"},
      {"id": "brd_456", "name": "Marriott"}
    ]})
  end

  defp brand_response do
    ~s({"data": {"id": "brd_123", "name": "Hilton"}})
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
