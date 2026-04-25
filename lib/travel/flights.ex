defmodule Travel.Flights do
  @moduledoc """
  Duffel Flights API namespace.

  Provides access to all Flights-related endpoints:

    * `Travel.Flights.OfferRequests` - Create and retrieve offer requests
    * `Travel.Flights.Offers` - Get, list, update, and price offers
    * `Travel.Flights.Orders` - Create, retrieve, list, and manage orders
    * `Travel.Flights.Payments` - Create payments for pay-later orders
    * `Travel.Flights.SeatMaps` - Get seat maps for offers
    * `Travel.Flights.OrderCancellations` - Create, retrieve, and confirm cancellations
    * `Travel.Flights.OrderChangeRequests` - Create and retrieve change requests
    * `Travel.Flights.OrderChangeOffers` - Get and list change offers
    * `Travel.Flights.OrderChanges` - Create, retrieve, and confirm order changes
    * `Travel.Flights.PartialOfferRequests` - Multi-step search partial offer requests
    * `Travel.Flights.BatchOfferRequests` - Long-polling batch offer requests
    * `Travel.Flights.AirlineInitiatedChanges` - List, accept, and update airline changes
  """
end
