defmodule Travel.Integration.FlightsBookingFlowTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag skip: System.get_env("DUFFEL_API_KEY") == nil

  test "complete flight booking flow: offer request -> order -> cancellation" do
    config = travel_config()

    departure_date = future_date(7)
    return_date = future_date(14)

    IO.puts("\n=== Flight Booking Flow Integration Test ===")

    IO.puts("\n1. Creating offer request (LHR -> JFK, #{departure_date})...")

    {:ok, offer_request_response} =
      Travel.Flights.OfferRequests.create(
        config,
        %{
          slices: [
            %{
              origin: "LHR",
              destination: "JFK",
              departure_date: departure_date
            },
            %{
              origin: "JFK",
              destination: "LHR",
              departure_date: return_date
            }
          ],
          passengers: [%{type: "adult"}]
        },
        %{return_offers: true}
      )

    assert %Travel.Flights.Types.OfferRequest{} = offer_request_response.data
    offer_request = offer_request_response.data
    IO.puts("   Offer request created: #{offer_request.id}")

    assert offer_request.offers != nil
    assert length(offer_request.offers) > 0
    IO.puts("   Found #{length(offer_request.offers)} offers")

    offer = hd(offer_request.offers)
    IO.puts("   Selected offer: #{offer.id} (#{offer.total_amount} #{offer.total_currency})")
    IO.puts("   Owner: #{offer.owner["name"]}")
    IO.puts("   Slices: #{length(offer.slices)}")

    passenger = hd(offer.passengers)

    IO.puts("\n2. Creating order...")

    {:ok, order_response} =
      Travel.Flights.Orders.create(config, %{
        type: "instant",
        selected_offers: [offer.id],
        payments: [
          %{
            type: "balance",
            amount: offer.total_amount,
            currency: offer.total_currency
          }
        ],
        passengers: [
          %{
            id: passenger.id,
            given_name: "Integration",
            family_name: "Test",
            born_on: "1990-01-01",
            gender: "m",
            title: "mr",
            email: "integration-test@travel-client.example.com",
            phone_number: "+442080160509"
          }
        ]
      })

    assert %Travel.Flights.Types.Order{} = order_response.data
    order = order_response.data
    IO.puts("   Order created: #{order.id}")
    IO.puts("   Booking reference: #{order.booking_reference}")
    IO.puts("   Total: #{order.total_amount} #{order.total_currency}")
    IO.puts("   Payment status: awaiting_payment=#{order.payment_status.awaiting_payment}")

    IO.puts("\n3. Retrieving order by ID...")

    {:ok, fetched_order_response} = Travel.Flights.Orders.get(config, order.id)
    assert fetched_order_response.data.id == order.id
    assert fetched_order_response.data.booking_reference == order.booking_reference
    IO.puts("   Order retrieved successfully")

    IO.puts("\n4. Listing orders...")

    {:ok, list_response} = Travel.Flights.Orders.list(config, %{limit: 5})
    assert length(list_response.data) > 0
    assert Enum.any?(list_response.data, fn o -> o.id == order.id end)
    IO.puts("   Found #{length(list_response.data)} orders (including our new order)")

    if order.cancellation != nil do
      IO.puts("\n5. Cancellation available, testing cancellation flow...")

      {:ok, cancellation_response} =
        Travel.Flights.OrderCancellations.create(config, %{
          order_id: order.id
        })

      assert %Travel.Flights.Types.OrderCancellation{} = cancellation_response.data
      cancellation = cancellation_response.data
      IO.puts("   Cancellation created: #{cancellation.id}")
      IO.puts("   Refund amount: #{cancellation.refund_amount} #{cancellation.refund_currency}")

      if cancellation.expires_at != nil && cancellation.confirmed_at == nil do
        IO.puts("   Confirming cancellation...")

        {:ok, confirmed_response} =
          Travel.Flights.OrderCancellations.confirm(config, cancellation.id)

        assert confirmed_response.data.confirmed_at != nil
        IO.puts("   Cancellation confirmed")
      else
        IO.puts("   Cancellation already confirmed or does not require confirmation")
      end
    else
      IO.puts("\n5. No cancellation available for this order (skipping cancellation)")
    end

    IO.puts("\n=== Flight Booking Flow Test Complete ===\n")
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
