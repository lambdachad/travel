defmodule Travel.Integration.StaysBookingFlowTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag skip: System.get_env("DUFFEL_API_KEY") == nil

  test "complete stays booking flow: search -> quote -> booking -> cancellation" do
    config = travel_config()

    check_in_date = future_date(30)
    check_out_date = future_date(34)

    IO.puts("\n=== Stays Booking Flow Integration Test ===")

    IO.puts("\n1. Searching for accommodations (London, #{check_in_date} - #{check_out_date})...")

    {:ok, search_response} =
      Travel.Stays.Search.search(config, %{
        location: %{
          geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
          radius: 5
        },
        check_in_date: check_in_date,
        check_out_date: check_out_date,
        rooms: 1,
        guests: [%{type: "adult"}]
      })

    assert %Travel.Stays.Types.StaysSearchResponse{} = search_response.data
    search_data = search_response.data
    IO.puts("   Search completed at: #{search_data.created_at}")
    IO.puts("   Found #{length(search_data.results)} results")

    assert length(search_data.results) > 0

    result = hd(search_data.results)
    IO.puts("   Selected: #{result.accommodation.name} (#{result.accommodation.id})")

    IO.puts(
      "   Cheapest rate: #{result.cheapest_rate_total_amount} #{result.cheapest_rate_currency}"
    )

    IO.puts("\n2. Fetching all rates for selected accommodation...")

    {:ok, rates_response} =
      Travel.Stays.SearchResults.fetch_all_rates(config, result.id)

    assert %Travel.Stays.Types.StaysSearchResult{} = rates_response.data
    search_result = rates_response.data

    assert length(search_result.accommodation.rooms) > 0

    room = hd(search_result.accommodation.rooms)
    IO.puts("   Room: #{room.name}")
    IO.puts("   Available rates: #{length(room.rates)}")

    assert length(room.rates) > 0

    rate = hd(room.rates)
    IO.puts("   Selected rate: #{rate.total_amount} #{rate.total_currency}")
    IO.puts("   Board type: #{rate.board_type}")
    IO.puts("   Payment type: #{rate.payment_type}")

    IO.puts("\n3. Creating quote...")

    {:ok, quote_response} = Travel.Stays.Quotes.create(config, rate.id)

    assert %Travel.Stays.Types.StaysQuote{} = quote_response.data
    quote = quote_response.data
    IO.puts("   Quote created: #{quote.id}")
    IO.puts("   Total: #{quote.total_amount} #{quote.total_currency}")
    IO.puts("   Check-in: #{quote.check_in_date}")
    IO.puts("   Check-out: #{quote.check_out_date}")

    IO.puts("\n4. Retrieving quote by ID...")

    {:ok, fetched_quote_response} = Travel.Stays.Quotes.get(config, quote.id)
    assert fetched_quote_response.data.id == quote.id
    IO.puts("   Quote retrieved successfully")

    IO.puts("\n5. Creating booking...")

    {:ok, booking_response} =
      Travel.Stays.Bookings.create(config, %{
        quote_id: quote.id,
        guests: [%{given_name: "Integration", family_name: "Test"}],
        email: "integration-test@travel-client.example.com",
        phone_number: "+442012345678"
      })

    assert %Travel.Stays.Types.StaysBooking{} = booking_response.data
    booking = booking_response.data
    IO.puts("   Booking created: #{booking.id}")
    IO.puts("   Reference: #{booking.reference}")
    IO.puts("   Status: #{booking.status}")
    IO.puts("   Accommodation: #{booking.accommodation.name}")

    IO.puts("\n6. Retrieving booking by ID...")

    {:ok, fetched_booking_response} = Travel.Stays.Bookings.get(config, booking.id)
    assert fetched_booking_response.data.id == booking.id
    assert fetched_booking_response.data.reference == booking.reference
    IO.puts("   Booking retrieved successfully")

    IO.puts("\n7. Listing bookings...")

    {:ok, list_response} = Travel.Stays.Bookings.list(config, %{limit: 5})
    assert length(list_response.data) > 0
    assert Enum.any?(list_response.data, fn b -> b.id == booking.id end)
    IO.puts("   Found #{length(list_response.data)} bookings (including our new booking)")

    IO.puts("\n8. Cancelling booking...")

    {:ok, cancelled_response} = Travel.Stays.Bookings.cancel(config, booking.id)
    assert cancelled_response.data.status == :cancelled
    assert cancelled_response.data.cancelled_at != nil
    IO.puts("   Booking cancelled successfully")
    IO.puts("   Cancelled at: #{cancelled_response.data.cancelled_at}")

    IO.puts("\n=== Stays Booking Flow Test Complete ===\n")
  end

  defp travel_config do
    access_token = System.fetch_env!("DUFFEL_API_KEY")

    Travel.new(
      access_token: access_token,
      debug: false
    )
  end

  defp future_date(days_from_now) do
    Date.utc_today()
    |> Date.add(days_from_now)
    |> Date.to_string()
  end
end
