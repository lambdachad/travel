# Travel

Duffel API client for Elixir. Search and book flights and hotels through a clean, idiomatic interface built on [Req](https://github.com/wojtekmach/req).

[![Hex.pm](https://img.shields.io/hexpm/v/travel.svg)](https://hex.pm/packages/travel)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/travel)
[![License](https://img.shields.io/hexpm/l/travel.svg)](https://github.com/lambdachad/travel/blob/main/LICENSE)

## Installation

Add `:travel` to your dependencies:

```elixir
def deps do
  [
    {:travel, "~> 0.1.0"}
  ]
end
```

Requires a [Duffel API access token](https://duffel.com/docs/api/overview/authentication). Get one at [app.duffel.com](https://app.duffel.com).

## Quick Start

```elixir
# Configure the client
config = Travel.new(access_token: "duffel_test_...")

# Search for hotels in London
{:ok, response} = Travel.Stays.Search.search(config, %{
  location: %{
    geographic_coordinates: %{latitude: 51.5074, longitude: -0.1278},
    radius: 10
  },
  check_in_date: "2026-08-01",
  check_out_date: "2026-08-03",
  rooms: 1,
  guests: [%{type: "adult"}]
})

response.data.results |> Enum.each(fn result ->
  IO.puts("#{result.accommodation.name} - #{result.cheapest_rate_total_amount} #{result.cheapest_rate_currency}")
end)

# Search for flights
{:ok, response} = Travel.Flights.OfferRequests.create(config, %{
  slices: [
    %{origin: "LHR", destination: "JFK", departure_date: "2026-08-01"}
  ],
  passengers: [%{type: "adult"}]
}, %{return_offers: true})

IO.puts("Found #{length(response.data.offers)} offers")
```

## Configuration

```elixir
config = Travel.new(
  access_token: "duffel_test_...",   # required
  base_url: "https://api.duffel.com", # optional, default
  api_version: "v2",                  # optional, default
  debug: false                        # optional, default
)
```

## Stays API

### Search

Search by location or by specific accommodation IDs:

```elixir
# Location-based search
{:ok, response} = Travel.Stays.Search.search(config, %{
  location: %{
    geographic_coordinates: %{latitude: 51.5, longitude: -0.1},
    radius: 10
  },
  check_in_date: "2026-08-01",
  check_out_date: "2026-08-03",
  rooms: 1,
  guests: [%{type: "adult"}, %{type: "child", age: 8}]
})

# Accommodation-based search
{:ok, response} = Travel.Stays.Search.search(config, %{
  accommodation: %{
    ids: ["acc_0000AZ2OJbCJNYH4Y2Zm5j"],
    fetch_rates: true
  },
  check_in_date: "2026-08-01",
  check_out_date: "2026-08-03",
  rooms: 1,
  guests: [%{type: "adult"}]
})
```

### Search Results

Fetch all rates for a search result:

```elixir
{:ok, response} = Travel.Stays.SearchResults.fetch_all_rates(config, "ser_123")
```

### Quotes

Create and retrieve quotes:

```elixir
# Create a quote from a rate
{:ok, response} = Travel.Stays.Quotes.create(config, "rate_123")

# Get a quote
{:ok, response} = Travel.Stays.Quotes.get(config, "quo_123")
```

### Bookings

Create, retrieve, list, and cancel bookings:

```elixir
# Create a booking
{:ok, response} = Travel.Stays.Bookings.create(config, %{
  quote_id: "quo_123",
  guests: [%{given_name: "John", family_name: "Smith"}],
  email: "john@example.com",
  phone_number: "+447700900000",
  loyalty_programme_account_number: "123456789",  # optional
  accommodation_special_requests: "Late check-in"  # optional
})

# Get a booking
{:ok, response} = Travel.Stays.Bookings.get(config, "bok_123")

# List bookings (paginated)
{:ok, response} = Travel.Stays.Bookings.list(config, %{limit: 20})

# Stream all bookings (handles pagination automatically)
Travel.Stays.Bookings.stream(config)
|> Enum.each(fn response ->
  Enum.each(response.data, fn booking ->
    IO.puts("#{booking.id} - #{booking.status}")
  end)
end)

# Cancel a booking
{:ok, response} = Travel.Stays.Bookings.cancel(config, "bok_123")
```

### Accommodation

```elixir
# Get by ID
{:ok, response} = Travel.Stays.Accommodation.get(config, "acc_123")

# List near a location
{:ok, response} = Travel.Stays.Accommodation.list(config, %{
  latitude: 51.5,
  longitude: -0.1,
  radius: 5
})

# Get suggestions
{:ok, response} = Travel.Stays.Accommodation.suggestions(config, "Hilton London")

# Get suggestions with location filter
{:ok, response} = Travel.Stays.Accommodation.suggestions(config, "Hilton", %{
  radius: 10,
  geographic_coordinates: %{latitude: 51.5, longitude: -0.1}
})

# Get reviews
{:ok, response} = Travel.Stays.Accommodation.reviews(config, "acc_123", %{limit: 10})
```

### Brands

```elixir
# List all brands
{:ok, response} = Travel.Stays.Brands.list(config)

# Get a brand
{:ok, response} = Travel.Stays.Brands.get(config, "brd_123")
```

### Loyalty Programmes

```elixir
{:ok, response} = Travel.Stays.LoyaltyProgrammes.list(config)
```

## Flights API

### Offer Requests

Create flight searches and retrieve offers:

```elixir
# Create and return offers
{:ok, response} = Travel.Flights.OfferRequests.create(config, %{
  slices: [
    %{origin: "LHR", destination: "JFK", departure_date: "2026-08-01"},
    %{origin: "JFK", destination: "LHR", departure_date: "2026-08-15"}
  ],
  passengers: [
    %{type: "adult"},
    %{type: "child", age: 8}
  ],
  cabin_class: "economy"
}, %{return_offers: true})

# Get an offer request
{:ok, response} = Travel.Flights.OfferRequests.get(config, "orq_123")

# List offer requests
{:ok, response} = Travel.Flights.OfferRequests.list(config, %{limit: 20})
```

### Offers

```elixir
# List offers for an offer request
{:ok, response} = Travel.Flights.Offers.list(config, "orq_123")

# Get a specific offer
{:ok, response} = Travel.Flights.Offers.get(config, "off_123", %{
  return_available_services: true
})

# Update passenger details
{:ok, response} = Travel.Flights.Offers.update(config, "off_123", "pas_123", %{
  given_name: "John",
  family_name: "Smith",
  loyalty_programme_accounts: [%{account_number: "123456", airline_iata_code: "BA"}]
})

# Price an offer
{:ok, response} = Travel.Flights.Offers.get_priced(config, "off_123", %{
  intended_payment_methods: [%{type: "balance"}],
  intended_services: []
})
```

### Orders

```elixir
# Create an order
{:ok, response} = Travel.Flights.Orders.create(config, %{
  selected_offers: ["off_123"],
  passengers: [
    %{
      given_name: "John",
      family_name: "Smith",
      born_on: "1990-01-01",
      gender: "m",
      title: "mr",
      email: "john@example.com",
      phone_number: "+447700900000"
    }
  ],
  type: "instant",
  metadata: %{"customer_ref" => "ABC123"}
})

# Get an order
{:ok, response} = Travel.Flights.Orders.get(config, "ord_123")

# List orders
{:ok, response} = Travel.Flights.Orders.list(config, %{
  awaiting_payment: true
})

# Update order metadata
{:ok, response} = Travel.Flights.Orders.update(config, "ord_123", %{
  metadata: %{"payment_intent_id" => "pit_123"}
})

# Get available services
{:ok, response} = Travel.Flights.Orders.get_available_services(config, "ord_123")

# Add services (baggage, seats)
{:ok, response} = Travel.Flights.Orders.add_services(config, "ord_123", %{
  payment: %{type: "balance", amount: "30.00", currency: "GBP"},
  add_services: [%{id: "asr_123", quantity: 1}]
})
```

### Payments

```elixir
# Pay for a pay-later order
{:ok, response} = Travel.Flights.Payments.create(config, %{
  order_id: "ord_123",
  payment: %{type: "balance", amount: "150.00", currency: "GBP"}
})
```

### Seat Maps

```elixir
{:ok, response} = Travel.Flights.SeatMaps.get(config, %{offer_id: "off_123"})
```

### Order Cancellations

```elixir
# Create a cancellation
{:ok, response} = Travel.Flights.OrderCancellations.create(config, %{
  order_id: "ord_123"
})

# Get a cancellation
{:ok, response} = Travel.Flights.OrderCancellations.get(config, "ore_123")

# List cancellations
{:ok, response} = Travel.Flights.OrderCancellations.list(config, %{order_id: "ord_123"})

# Confirm a cancellation
{:ok, response} = Travel.Flights.OrderCancellations.confirm(config, "ore_123")
```

### Order Changes

```elixir
# Create a change request
{:ok, response} = Travel.Flights.OrderChangeRequests.create(config, %{
  order_id: "ord_123",
  slices: %{
    add: [%{origin: "LHR", destination: "CDG", departure_date: "2026-09-01"}],
    remove: [%{slice_id: "sli_123"}]
  }
})

# List change offers for a change request
{:ok, response} = Travel.Flights.OrderChangeOffers.list(config, %{
  order_change_request_id: "ocr_123"
})

# Create an order change
{:ok, response} = Travel.Flights.OrderChanges.create(config, %{
  selected_order_change_offer: "oco_123"
})

# Confirm the change (without payment)
{:ok, response} = Travel.Flights.OrderChanges.confirm(config, "orc_123")

# Confirm with payment
{:ok, response} = Travel.Flights.OrderChanges.confirm(config, "orc_123", %{
  payment: %{type: "balance", amount: "50.00", currency: "GBP"}
})
```

### Batch Offer Requests

For long-polling searches that return offers incrementally:

```elixir
# Create
{:ok, response} = Travel.Flights.BatchOfferRequests.create(config, %{
  slices: [...],
  passengers: [...]
})

# Poll for results
{:ok, response} = Travel.Flights.BatchOfferRequests.get(config, "bor_123")
```

### Partial Offer Requests

For multi-step search flows:

```elixir
{:ok, response} = Travel.Flights.PartialOfferRequests.create(config, %{
  slices: [...],
  passengers: [...]
})

{:ok, response} = Travel.Flights.PartialOfferRequests.get(config, "por_123", %{
  selected_partial_offer: "off_123"
})

# Get fares for a partial offer request
{:ok, response} = Travel.Flights.PartialOfferRequests.get_fares_by_id(config, "por_123", %{
  selected_partial_offer: "off_456"
})
```

### Airline-Initiated Changes

```elixir
# List changes for an order
{:ok, response} = Travel.Flights.AirlineInitiatedChanges.list(config, %{order_id: "ord_123"})

# Accept a change
{:ok, response} = Travel.Flights.AirlineInitiatedChanges.accept(config, "aic_123")

# Update with action taken
{:ok, response} = Travel.Flights.AirlineInitiatedChanges.update(config, "aic_123", %{
  action_taken: "accepted"
})
```

### Airline Credits

```elixir
# Create an airline credit
{:ok, response} = Travel.Flights.AirlineCredits.create(config, %{
  airline_iata_code: "BA",
  amount: "100.00",
  amount_currency: "GBP",
  code: "1234567890123",
  type: "eticket",
  issued_on: "2026-01-15",
  expires_at: "2027-01-15T00:00:00Z"
})

# Get an airline credit
{:ok, response} = Travel.Flights.AirlineCredits.get(config, "acd_123")

# List airline credits
{:ok, response} = Travel.Flights.AirlineCredits.list(config, %{user_id: "icu_123"})
```

## Response Format

All functions return `{:ok, response} | {:error, error}` tuples.

### Success Response

```elixir
{:ok, %Travel.Types.DuffelResponse{
  data: %Travel.Stays.Types.StaysBooking{...},
  meta: %Travel.Types.PaginationMeta{limit: 20, after: "cursor_abc", before: nil},
  status: 200,
  headers: %{"x-request-id" => ["req_123"]}
}}
```

### Error Response

```elixir
{:error, %Travel.Error{
  status: 400,
  code: "invalid_request",
  message: "Field 'check_in_date' must be after today",
  title: "Bad Request",
  type: "validation_error",
  request_id: "req_123",
  documentation_url: "https://duffel.com/docs/api/errors"
}}
```

## Pagination

List endpoints support cursor-based pagination:

```elixir
# Single page
{:ok, response} = Travel.Stays.Bookings.list(config, %{limit: 20, after: "cursor_abc"})

# Auto-paginating stream
Travel.Stays.Bookings.stream(config)
|> Stream.flat_map(& &1.data)
|> Enum.to_list()
```

## Testing

```bash
mix test
```

All tests use [Bypass](https://github.com/PSPDFKit-labs/bypass) for HTTP mocking — no network or API credentials required.

## License

MIT
