defmodule Travel.Stays.LoyaltyProgrammesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "list/1" do
    test "sends GET to /stays/loyalty_programmes", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/loyalty_programmes", fn conn ->
        conn
        |> Plug.Conn.resp(200, loyalty_programmes_response())
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:ok, response} = Travel.Stays.LoyaltyProgrammes.list(config)

      assert response.status == 200
      assert length(response.data) == 2
      assert %Travel.Stays.Types.StaysLoyaltyProgramme{} = hd(response.data)
      assert hd(response.data).reference == :marriott_bonvoy
      assert hd(response.data).name == "Marriott Bonvoy"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/stays/loyalty_programmes", fn conn ->
        conn
        |> Plug.Conn.resp(401, error_response("Unauthorized"))
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      config = travel_config(bypass.port)
      {:error, error} = Travel.Stays.LoyaltyProgrammes.list(config)

      assert error.status == 401
    end
  end

  defp loyalty_programmes_response do
    ~s({"data": [
      {
        "reference": "marriott_bonvoy",
        "name": "Marriott Bonvoy",
        "logo_url_svg": "https://example.com/marriott.svg",
        "logo_url_png_small": "https://example.com/marriott.png"
      },
      {
        "reference": "hilton_honors",
        "name": "Hilton Honors",
        "logo_url_svg": "https://example.com/hilton.svg",
        "logo_url_png_small": "https://example.com/hilton.png"
      }
    ]})
  end

  defp error_response(message) do
    ~s({
      "meta": {"request_id": "req_123"},
      "errors": [{"code": "internal_server_error", "message": "#{message}", "title": "Server Error", "type": "server_error", "documentation_url": ""}]
    })
  end

  defp travel_config(port) do
    Travel.new(access_token: "test_token", base_url: "http://localhost:#{port}")
  end
end
