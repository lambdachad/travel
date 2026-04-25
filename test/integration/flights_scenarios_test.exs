defmodule Travel.Integration.FlightsScenariosTest do
  use ExUnit.Case

  @moduletag :integration
  @moduletag skip: System.get_env("DUFFEL_API_KEY") == nil

  defp config do
    Travel.new(access_token: System.fetch_env!("DUFFEL_API_KEY"))
  end

  defp future_date(days), do: Date.utc_today() |> Date.add(days) |> Date.to_string()

  defp passenger_params(id) do
    %{
      id: id,
      given_name: "Integration",
      family_name: "Test",
      born_on: "1990-01-01",
      gender: "m",
      title: "mr",
      email: "integration-test@travel-client.example.com",
      phone_number: "+442080160509"
    }
  end

  defp order_params(offer, type \\ "instant") do
    %{
      type: type,
      selected_offers: [offer.id],
      payments: [
        %{
          type: "balance",
          amount: offer.total_amount,
          currency: offer.total_currency
        }
      ],
      passengers: [passenger_params(hd(offer.passengers).id)]
    }
  end

  defp create_offer_request(origin, destination) do
    Travel.Flights.OfferRequests.create(
      config(),
      %{
        slices: [%{origin: origin, destination: destination, departure_date: future_date(30)}],
        passengers: [%{type: "adult"}]
      },
      %{return_offers: true}
    )
  end

  describe "offer request scenarios" do
    test "no flights returns empty offers (PVD -> RAI)" do
      {:ok, response} = create_offer_request("PVD", "RAI")

      assert response.data.offers == []
    end

    test "connecting flights have multiple segments (LHR -> DXB)" do
      {:ok, response} = create_offer_request("LHR", "DXB")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)
      slice = hd(offer.slices)
      assert length(slice.segments) > 1
    end

    test "hold order route returns requires_instant_payment=false (JFK -> EWR)" do
      {:ok, response} = create_offer_request("JFK", "EWR")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)
      assert offer.payment_requirements != nil
      refute offer.payment_requirements.requires_instant_payment
    end

    test "no baggage scenario (BTS -> MRU)" do
      {:ok, response} = create_offer_request("BTS", "MRU")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)
      slice = hd(offer.slices)
      segment = hd(slice.segments)

      for passenger <- segment.passengers do
        assert passenger.baggages == []
      end
    end
  end

  describe "offer scenarios" do
    test "no additional services (BTS -> ABV)" do
      {:ok, response} = create_offer_request("BTS", "ABV")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:ok, fetched} =
        Travel.Flights.Offers.get(config(), offer.id, %{return_available_services: true})

      assert fetched.data.available_services == []
    end

    test "offer no longer available (LGW -> LHR)" do
      {:ok, response} = create_offer_request("LGW", "LHR")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:error, error} = Travel.Flights.Offers.get(config(), offer.id)

      assert error.status in [400, 404, 422]
    end

    test "offer price change (LHR -> STN)" do
      {:ok, response} = create_offer_request("LHR", "STN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)
      original_price = offer.total_amount

      {:ok, fetched} = Travel.Flights.Offers.get(config(), offer.id)

      assert fetched.data.total_amount != original_price
    end
  end

  describe "order scenarios" do
    test "order creation error (LHR -> LGW)" do
      {:ok, response} = create_offer_request("LHR", "LGW")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:error, error} = Travel.Flights.Orders.create(config(), order_params(offer))

      assert error.status in [400, 422, 502]
    end

    test "insufficient balance error (LGW -> STN)" do
      {:ok, response} = create_offer_request("LGW", "STN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:error, error} = Travel.Flights.Orders.create(config(), order_params(offer))

      assert error.status in [400, 402, 422]
    end

    test "offer no longer available on booking (LHR -> STN)" do
      {:ok, response} = create_offer_request("LHR", "STN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:error, error} = Travel.Flights.Orders.create(config(), order_params(offer))

      assert error.status in [400, 422]
    end

    test "card payment 200 - order created but not yet updated (LTN -> STN)" do
      {:ok, response} = create_offer_request("LTN", "STN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      params = %{
        type: "instant",
        selected_offers: [offer.id],
        payments: [
          %{
            type: "card",
            card_id: "tcd_123",
            amount: offer.total_amount,
            currency: offer.total_currency
          }
        ],
        passengers: [passenger_params(hd(offer.passengers).id)]
      }

      result = Travel.Flights.Orders.create(config(), params)

      case result do
        {:ok, order_response} ->
          assert order_response.data.id != nil
          assert order_response.status in [200, 201, 202]

        {:error, error} ->
          assert error.status in [400, 422]
      end
    end

    test "card payment 202 - accepted but not yet confirmed (SEN -> STN)" do
      {:ok, response} = create_offer_request("SEN", "STN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      params = %{
        type: "instant",
        selected_offers: [offer.id],
        payments: [
          %{
            type: "card",
            card_id: "tcd_123",
            amount: offer.total_amount,
            currency: offer.total_currency
          }
        ],
        passengers: [passenger_params(hd(offer.passengers).id)]
      }

      result = Travel.Flights.Orders.create(config(), params)

      case result do
        {:ok, order_response} ->
          assert order_response.data.id != nil
          assert order_response.status in [200, 201, 202]

        {:error, error} ->
          assert error.status in [400, 422]
      end
    end
  end

  describe "hold order + payment flow" do
    test "create hold order then pay (JFK -> EWR)" do
      {:ok, response} = create_offer_request("JFK", "EWR")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)
      refute offer.payment_requirements.requires_instant_payment

      passenger = hd(offer.passengers)

      {:ok, order_response} =
        Travel.Flights.Orders.create(config(), %{
          type: "hold",
          selected_offers: [offer.id],
          passengers: [passenger_params(passenger.id)]
        })

      order = order_response.data
      assert order.id != nil
      assert order.payment_status.awaiting_payment == true

      result =
        Travel.Flights.Payments.create(config(), %{
          order_id: order.id,
          payment: %{
            type: "card",
            card_id: "tcd_123",
            amount: order.total_amount,
            currency: order.total_currency
          }
        })

      case result do
        {:ok, payment_response} ->
          assert payment_response.data.id != nil
          assert payment_response.data.amount != nil

        {:error, error} ->
          assert error.status in [400, 422]
      end
    end
  end

  describe "airline-initiated changes" do
    test "simulate and list changes (LHR -> LTN)" do
      {:ok, response} = create_offer_request("LHR", "LTN")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:ok, order_response} =
        Travel.Flights.Orders.create(config(), order_params(offer))

      order = order_response.data

      {:ok, changes_response} =
        Travel.Flights.AirlineInitiatedChanges.list(config(), order.id)

      assert length(changes_response.data) > 0

      change = hd(changes_response.data)
      assert change.order_id == order.id
      assert change.available_actions != nil
    end
  end

  describe "cancellation with airline credits" do
    test "cancelled order refunded to airline credits (LTN -> SYD)" do
      {:ok, response} = create_offer_request("LTN", "SYD")

      assert length(response.data.offers) > 0
      offer = hd(response.data.offers)

      {:ok, order_response} =
        Travel.Flights.Orders.create(config(), order_params(offer))

      order = order_response.data

      {:ok, cancellation_response} =
        Travel.Flights.OrderCancellations.create(config(), %{order_id: order.id})

      cancellation = cancellation_response.data
      assert cancellation.refund_to == :airline_credits

      if cancellation.expires_at != nil && cancellation.confirmed_at == nil do
        {:ok, confirmed} =
          Travel.Flights.OrderCancellations.confirm(config(), cancellation.id)

        assert confirmed.data.confirmed_at != nil
        assert length(confirmed.data.airline_credits) > 0
      end
    end
  end
end
