defmodule TravelTest do
  use ExUnit.Case
  doctest Travel

  describe "new/1" do
    test "creates config with required access_token" do
      config = Travel.new(access_token: "test_token")
      assert config.access_token == "test_token"
      assert config.base_url == "https://api.duffel.com"
      assert config.api_version == "v2"
      assert config.debug == false
    end

    test "allows overriding defaults" do
      config =
        Travel.new(
          access_token: "test",
          base_url: "http://localhost:4000",
          api_version: "v1",
          debug: true
        )

      assert config.base_url == "http://localhost:4000"
      assert config.api_version == "v1"
      assert config.debug == true
    end
  end
end
