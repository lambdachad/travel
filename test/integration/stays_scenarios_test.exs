defmodule Travel.Integration.StaysScenariosTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag skip: System.get_env("DUFFEL_API_KEY") == nil

  defp config do
    Travel.new(access_token: System.fetch_env!("DUFFEL_API_KEY"))
  end

  defp future_date(days), do: Date.utc_today() |> Date.add(days) |> Date.to_string()

  describe "search scenarios" do
    test "search returns results for valid location (London)" do
      {:ok, response} =
        Travel.Stays.Search.search(config(), %{
          location: %{
            geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
            radius: 5
          },
          check_in_date: future_date(30),
          check_out_date: future_date(34),
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      assert length(response.data.results) > 0
      result = hd(response.data.results)
      assert result.accommodation.id != nil
      assert result.accommodation.name != nil
      assert result.cheapest_rate_total_amount != nil
    end

    test "search by accommodation ID with fetch_rates" do
      {:ok, search_response} =
        Travel.Stays.Search.search(config(), %{
          location: %{
            geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
            radius: 5
          },
          check_in_date: future_date(30),
          check_out_date: future_date(34),
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      assert length(search_response.data.results) > 0
      accommodation_id = hd(search_response.data.results).accommodation.id

      {:ok, response} =
        Travel.Stays.Search.search(config(), %{
          accommodation: %{
            ids: [accommodation_id],
            fetch_rates: true
          },
          check_in_date: future_date(30),
          check_out_date: future_date(34),
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      assert length(response.data.results) > 0
      result = hd(response.data.results)
      assert result.accommodation.id == accommodation_id
      assert length(result.accommodation.rooms) > 0
    end
  end

  describe "accommodation scenarios" do
    test "get accommodation by ID" do
      {:ok, search_response} =
        Travel.Stays.Search.search(config(), %{
          location: %{
            geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
            radius: 5
          },
          check_in_date: future_date(30),
          check_out_date: future_date(34),
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      accommodation_id = hd(search_response.data.results).accommodation.id

      {:ok, response} = Travel.Stays.Accommodation.get(config(), accommodation_id)

      assert response.data.id == accommodation_id
      assert response.data.name != nil
      assert response.data.location != nil
    end

    test "list accommodations with pagination" do
      {:ok, response} =
        Travel.Stays.Accommodation.list(config(), %{
          latitude: 51.5074,
          longitude: -0.1278,
          radius: 5,
          limit: 5
        })

      assert length(response.data) > 0
      assert length(response.data) <= 5
    end

    test "accommodation suggestions" do
      {:ok, response} =
        Travel.Stays.Accommodation.suggestions(config(), "Raffles London", %{
          geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278}
        })

      assert length(response.data) > 0
      suggestion = hd(response.data)
      assert suggestion.accommodation_id != nil
      assert suggestion.accommodation_name != nil
    end

    test "accommodation reviews" do
      {:ok, search_response} =
        Travel.Stays.Search.search(config(), %{
          location: %{
            geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
            radius: 5
          },
          check_in_date: future_date(30),
          check_out_date: future_date(34),
          rooms: 1,
          guests: [%{type: "adult"}]
        })

      accommodation_id = hd(search_response.data.results).accommodation.id

      {:ok, response} =
        Travel.Stays.Accommodation.reviews(config(), accommodation_id, %{limit: 5})

      assert response.data.reviews != nil
    end
  end

  describe "brands and loyalty programmes" do
    test "list brands" do
      {:ok, response} = Travel.Stays.Brands.list(config())

      assert length(response.data) > 0
      brand = hd(response.data)
      assert brand.id != nil
      assert brand.name != nil
    end

    test "get brand by ID" do
      {:ok, list_response} = Travel.Stays.Brands.list(config())

      brand_id = hd(list_response.data).id

      {:ok, response} = Travel.Stays.Brands.get(config(), brand_id)

      assert response.data.id == brand_id
    end

    test "list loyalty programmes" do
      {:ok, response} = Travel.Stays.LoyaltyProgrammes.list(config())

      assert length(response.data) > 0
      programme = hd(response.data)
      assert programme.reference != nil
      assert programme.name != nil
    end
  end
end
