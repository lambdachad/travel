defmodule Travel.Flights.Types do
  @moduledoc """
  Types for the Duffel Flights API.
  """

  use TypedStruct

  typedstruct module: PlaceAirport do
    field(:type, atom(), default: :airport)
    field(:id, String.t())
    field(:name, String.t())
    field(:time_zone, String.t() | nil)
    field(:iata_code, String.t())
    field(:iata_country_code, String.t())
    field(:city_name, String.t() | nil)
    field(:city, map() | nil)
    field(:country, map() | nil)
  end

  typedstruct module: PlaceCity do
    field(:type, atom(), default: :city)
    field(:id, String.t())
    field(:name, String.t())
    field(:iata_code, String.t())
    field(:iata_country_code, String.t())
    field(:airports, list(map()) | nil)
    field(:country, map() | nil)
  end

  typedstruct module: CabinClassMarketing do
    field(:name, String.t())
  end

  typedstruct module: OfferSliceSegmentPassengerBaggage do
    field(:type, String.t() | nil)
    field(:quantity, integer())
  end

  typedstruct module: OfferSliceSegmentPassenger do
    field(:passenger_id, String.t())
    field(:cabin_class, atom())
    field(:cabin_class_marketing_name, String.t())
    field(:fare_basis_code, String.t())
    field(:baggages, list(OfferSliceSegmentPassengerBaggage.t()))
    field(:cabin, CabinClassMarketing.t() | nil)
  end

  typedstruct module: OfferSliceSegmentStop do
    field(:id, String.t())
    field(:duration, String.t() | nil)
    field(:destination, PlaceAirport.t())
  end

  typedstruct module: OfferSliceSegment do
    field(:id, String.t())
    field(:origin, PlaceAirport.t())
    field(:destination, PlaceAirport.t())
    field(:departure_at, String.t())
    field(:arriving_at, String.t())
    field(:duration, String.t())
    field(:distance, String.t() | nil)
    field(:marketing_carrier, map())
    field(:operating_carrier, map())
    field(:marketing_carrier_flight_number, String.t())
    field(:operating_carrier_flight_number, String.t() | nil)
    field(:origin_terminal, String.t() | nil)
    field(:destination_terminal, String.t() | nil)
    field(:aircraft, map() | nil)
    field(:passengers, list(OfferSliceSegmentPassenger.t()))
    field(:stops, list(OfferSliceSegmentStop.t()))
  end

  typedstruct module: OfferSliceCondition do
    field(:change_before_departure, map() | nil)
    field(:refund_before_departure, map() | nil)
    field(:advance_seat_selection, map() | nil)
    field(:priority_boarding, map() | nil)
    field(:priority_check_in, map() | nil)
  end

  typedstruct module: OfferSlice do
    field(:id, String.t())
    field(:origin_type, atom())
    field(:destination_type, atom())
    field(:origin, map())
    field(:destination, map())
    field(:duration, String.t())
    field(:fare_brand_name, String.t() | nil)
    field(:segments, list(OfferSliceSegment.t()))
    field(:conditions, OfferSliceCondition.t())
    field(:ngs_shelf, integer() | nil)
  end

  typedstruct module: OfferPassenger do
    field(:id, String.t())
    field(:age, integer() | nil)
    field(:type, atom())
    field(:given_name, String.t() | nil)
    field(:family_name, String.t() | nil)
    field(:fare_type, atom() | nil)
    field(:loyalty_programme_accounts, list(map()) | nil)
  end

  typedstruct module: OfferAvailableServiceBaggageMetadata do
    field(:segment_ids, list(String.t()))
    field(:passenger_id, String.t())
    field(:max_weight_kg, integer() | nil)
    field(:max_height_cm, integer() | nil)
    field(:max_length_cm, integer() | nil)
    field(:max_depth_cm, integer() | nil)
    field(:type, String.t())
  end

  typedstruct module: OfferAvailableService do
    field(:id, String.t())
    field(:type, atom())
    field(:passenger_ids, list(String.t()))
    field(:segment_ids, list(String.t()))
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:metadata, map() | nil)
  end

  typedstruct module: OfferPrivateFare do
    field(:type, atom())
    field(:corporate_code, String.t() | nil)
    field(:tracking_reference, String.t() | nil)
  end

  typedstruct module: PaymentRequirements do
    field(:payment_required_by, String.t() | nil)
    field(:price_guarantee_expires_at, String.t() | nil)
    field(:requires_instant_payment, boolean())
  end

  typedstruct module: Offer do
    field(:id, String.t())
    field(:owner, map())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:expires_at, String.t())
    field(:slices, list(OfferSlice.t()))
    field(:passengers, list(OfferPassenger.t()))
    field(:conditions, map())
    field(:available_services, list(OfferAvailableService.t()))
    field(:private_fares, list(OfferPrivateFare.t()))
    field(:payment_requirements, PaymentRequirements.t())
    field(:partial, boolean(), default: false)
    field(:supported_loyalty_programmes, list(atom()) | nil)
    field(:supported_passenger_identity_document_types, list(atom()) | nil)
    field(:total_emissions_kg, String.t() | nil)
    field(:live_mode, boolean())
    field(:created_at, String.t())
    field(:updated_at, String.t() | nil)
  end

  typedstruct module: OfferPriced do
    field(:id, String.t())
    field(:owner, map())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:expires_at, String.t())
    field(:slices, list(OfferSlice.t()))
    field(:passengers, list(OfferPassenger.t()))
    field(:conditions, map())
    field(:available_services, list(OfferAvailableService.t()))
    field(:private_fares, list(OfferPrivateFare.t()))
    field(:payment_requirements, PaymentRequirements.t())
    field(:partial, boolean(), default: false)
    field(:supported_loyalty_programmes, list(atom()) | nil)
    field(:total_emissions_kg, String.t() | nil)
    field(:live_mode, boolean())
    field(:created_at, String.t())
    field(:updated_at, String.t() | nil)
    field(:intended_payment_methods, list(map()))
    field(:intended_services, list(map()))
  end

  typedstruct module: OfferRequestSlice do
    field(:origin_type, atom())
    field(:destination_type, atom())
    field(:origin, map())
    field(:destination, map())
    field(:departure_date, String.t())
  end

  typedstruct module: OfferRequestPassenger do
    field(:id, String.t())
    field(:age, integer() | nil)
    field(:type, atom())
    field(:given_name, String.t() | nil)
    field(:family_name, String.t() | nil)
    field(:loyalty_programme_accounts, list(map()) | nil)
  end

  typedstruct module: OfferRequest do
    field(:id, String.t())
    field(:live_mode, boolean())
    field(:created_at, String.t())
    field(:slices, list(OfferRequestSlice.t()))
    field(:passengers, list(OfferRequestPassenger.t()))
    field(:cabin_class, atom() | nil)
    field(:max_connections, integer() | nil)
    field(:private_fares, list(OfferPrivateFare.t()) | nil)
    field(:offers, list(Offer.t()) | nil)
  end

  typedstruct module: OrderService do
    field(:id, String.t())
    field(:type, atom())
    field(:passenger_ids, list(String.t()))
    field(:segment_ids, list(String.t()))
    field(:quantity, integer())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:metadata, map() | nil)
  end

  typedstruct module: OrderSliceSegmentPassengerBaggage do
    field(:type, String.t() | nil)
    field(:quantity, integer())
  end

  typedstruct module: OrderSliceSegmentPassenger do
    field(:passenger_id, String.t())
    field(:cabin_class, atom())
    field(:cabin_class_marketing_name, String.t())
    field(:fare_basis_code, String.t())
    field(:baggages, list(OrderSliceSegmentPassengerBaggage.t()))
    field(:cabin, CabinClassMarketing.t() | nil)
  end

  typedstruct module: OrderSliceSegmentStop do
    field(:id, String.t())
    field(:duration, String.t() | nil)
    field(:destination, PlaceAirport.t())
  end

  typedstruct module: OrderSliceSegment do
    field(:id, String.t())
    field(:origin, PlaceAirport.t())
    field(:destination, PlaceAirport.t())
    field(:departure_at, String.t())
    field(:arriving_at, String.t())
    field(:duration, String.t())
    field(:distance, String.t() | nil)
    field(:marketing_carrier, map())
    field(:operating_carrier, map())
    field(:marketing_carrier_flight_number, String.t())
    field(:operating_carrier_flight_number, String.t() | nil)
    field(:origin_terminal, String.t() | nil)
    field(:destination_terminal, String.t() | nil)
    field(:aircraft, map() | nil)
    field(:passengers, list(OrderSliceSegmentPassenger.t()))
    field(:stops, list(OrderSliceSegmentStop.t()))
  end

  typedstruct module: OrderSlice do
    field(:id, String.t())
    field(:origin_type, atom())
    field(:destination_type, atom())
    field(:origin, map())
    field(:destination, map())
    field(:duration, String.t())
    field(:fare_brand_name, String.t() | nil)
    field(:segments, list(OrderSliceSegment.t()))
    field(:conditions, OfferSliceCondition.t())
    field(:ngs_shelf, integer() | nil)
  end

  typedstruct module: OrderPassenger do
    field(:id, String.t())
    field(:born_on, String.t())
    field(:family_name, String.t())
    field(:given_name, String.t())
    field(:gender, atom())
    field(:title, atom())
    field(:type, atom())
    field(:email, String.t())
    field(:phone_number, String.t())
    field(:infant_passenger_id, String.t() | nil)
    field(:loyalty_programme_accounts, list(map()) | nil)
  end

  typedstruct module: OrderPaymentStatus do
    field(:awaiting_payment, boolean())
    field(:payment_required_by, String.t() | nil)
    field(:price_guarantee_expires_at, String.t() | nil)
    field(:paid_at, String.t() | nil)
  end

  typedstruct module: OrderCancellationAirlineCredit do
    field(:id, String.t())
    field(:credit_name, String.t())
    field(:credit_code, String.t())
    field(:credit_amount, String.t())
    field(:credit_currency, String.t())
    field(:issued_on, String.t())
    field(:passenger_id, String.t())
  end

  typedstruct module: OrderCancellation do
    field(:id, String.t())
    field(:order_id, String.t())
    field(:created_at, String.t())
    field(:confirmed_at, String.t() | nil)
    field(:expires_at, String.t() | nil)
    field(:live_mode, boolean())
    field(:refund_amount, String.t() | nil)
    field(:refund_currency, String.t() | nil)
    field(:refund_to, atom() | nil)
    field(:airline_credits, list(OrderCancellationAirlineCredit.t()))
  end

  typedstruct module: OrderChangeOfferSlice do
    field(:id, String.t())
    field(:origin_type, atom())
    field(:destination_type, atom())
    field(:origin, map())
    field(:destination, map())
    field(:duration, String.t() | nil)
    field(:fare_brand_name, String.t() | nil)
    field(:segments, list(OfferSliceSegment.t()))
  end

  typedstruct module: OrderChangeOfferSlices do
    field(:add, list(OrderChangeOfferSlice.t()))
    field(:remove, list(OrderChangeOfferSlice.t()))
  end

  typedstruct module: OrderChangeOffer do
    field(:id, String.t())
    field(:order_id, String.t() | nil)
    field(:change_total_amount, String.t())
    field(:change_total_currency, String.t())
    field(:new_total_amount, String.t())
    field(:new_total_currency, String.t())
    field(:penalty_amount, String.t())
    field(:penalty_currency, String.t())
    field(:refund_to, atom() | nil)
    field(:slices, OrderChangeOfferSlices.t())
    field(:expires_at, String.t())
    field(:created_at, String.t())
    field(:updated_at, String.t() | nil)
    field(:order_change_id, String.t() | nil)
  end

  typedstruct module: OrderChange do
    field(:id, String.t())
    field(:order_id, String.t())
    field(:change_total_amount, String.t())
    field(:change_total_currency, String.t())
    field(:new_total_amount, String.t())
    field(:new_total_currency, String.t())
    field(:penalty_total_amount, String.t())
    field(:penalty_total_currency, String.t())
    field(:refund_to, atom() | nil)
    field(:slices, OrderChangeOfferSlices.t())
    field(:expires_at, String.t())
    field(:created_at, String.t())
    field(:confirmed_at, String.t() | nil)
    field(:live_mode, boolean())
    field(:available_payment_types, list(atom()) | nil)
  end

  typedstruct module: OrderChangeRequestResponse do
    field(:id, String.t())
    field(:order_id, String.t())
    field(:live_mode, boolean())
    field(:slices, map())
    field(:order_change_offers, list(OrderChangeOffer.t()))
  end

  typedstruct module: BatchOfferRequest do
    field(:id, String.t())
    field(:created_at, String.t())
    field(:live_mode, boolean())
    field(:client_key, String.t() | nil)
    field(:total_batches, integer())
    field(:remaining_batches, integer())
    field(:offers, list(Offer.t()))
  end

  typedstruct module: CreateBatchOfferRequestResponse do
    field(:id, String.t())
    field(:created_at, String.t())
    field(:live_mode, boolean())
    field(:client_key, String.t() | nil)
    field(:total_batches, integer())
    field(:remaining_batches, integer())
  end

  typedstruct module: TravelAgentTicket do
    field(:id, String.t())
    field(:external_ticket_id, String.t())
  end

  typedstruct module: AirlineInitiatedChange do
    field(:id, String.t())
    field(:order_id, String.t())
    field(:action_taken, atom() | nil)
    field(:action_taken_at, String.t() | nil)
    field(:created_at, String.t())
    field(:updated_at, String.t())
    field(:added, list(OrderSlice.t()))
    field(:removed, list(OrderSlice.t()))
    field(:available_actions, list(atom()))
    field(:travel_agent_ticket, TravelAgentTicket.t() | nil)
  end

  typedstruct module: SeatMapCabinRowSectionElement do
    field(:type, atom())
    field(:designator, String.t() | nil)
    field(:name, String.t() | nil)
    field(:disclosures, list(String.t()))
    field(:available_services, list(map()))
  end

  typedstruct module: SeatMapCabinRowSection do
    field(:elements, list(SeatMapCabinRowSectionElement.t()))
  end

  typedstruct module: SeatMapCabinRow do
    field(:sections, list(SeatMapCabinRowSection.t()))
  end

  typedstruct module: SeatMapCabinWing do
    field(:rows, list(integer()))
  end

  typedstruct module: SeatMapCabin do
    field(:deck, String.t())
    field(:cabin_class, atom())
    field(:wings, list(SeatMapCabinWing.t()) | nil)
    field(:aisles, list(map()))
    field(:rows, list(SeatMapCabinRow.t()))
  end

  typedstruct module: SeatMap do
    field(:id, String.t())
    field(:slice_id, String.t())
    field(:segment_id, String.t())
    field(:cabins, list(SeatMapCabin.t()))
  end

  typedstruct module: Order do
    field(:id, String.t())
    field(:booking_reference, String.t())
    field(:owner, map())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:slices, list(OrderSlice.t()))
    field(:services, list(OrderService.t()))
    field(:passengers, list(OrderPassenger.t()))
    field(:payment_status, OrderPaymentStatus.t())
    field(:live_mode, boolean())
    field(:documents, list(map()) | nil)
    field(:created_at, String.t())
    field(:cancelled_at, String.t() | nil)
    field(:conditions, map())
    field(:metadata, map() | nil)
    field(:airline_initiated_changes, list(AirlineInitiatedChange.t()))
    field(:available_actions, list(atom()))
    field(:synced_at, String.t() | nil)
    field(:cancellation, OrderCancellation.t() | nil)
  end

  typedstruct module: Payment do
    field(:id, String.t())
    field(:amount, String.t())
    field(:currency, String.t() | nil)
    field(:type, atom())
    field(:status, atom() | nil)
    field(:failure_reason, String.t() | nil)
    field(:order_id, String.t() | nil)
    field(:airline_credit_id, String.t() | nil)
    field(:live_mode, boolean() | nil)
    field(:created_at, String.t())
  end

  typedstruct module: AirlineCredit do
    field(:id, String.t())
    field(:order_id, String.t())
    field(:amount, String.t())
    field(:currency, String.t())
    field(:created_at, String.t())
    field(:live_mode, boolean() | nil)
  end

  typedstruct module: ComponentClientKey do
    field(:component_client_key, String.t())
  end

  @doc """
  Parses a raw map into an `Offer` struct.
  """
  @spec parse_offer(map()) :: Offer.t()
  def parse_offer(data) do
    %Offer{
      id: data["id"],
      owner: data["owner"],
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      base_amount: data["base_amount"],
      base_currency: data["base_currency"],
      tax_amount: data["tax_amount"],
      tax_currency: data["tax_currency"],
      expires_at: data["expires_at"],
      slices: parse_list(data["slices"], &parse_offer_slice/1),
      passengers: parse_list(data["passengers"], &parse_offer_passenger/1),
      conditions: data["conditions"],
      available_services: parse_list(data["available_services"], &parse_available_service/1),
      private_fares: parse_list(data["private_fares"], &parse_private_fare/1),
      payment_requirements: parse_payment_requirements(data["payment_requirements"]),
      partial: data["partial"] || false,
      supported_loyalty_programmes:
        parse_list(data["supported_loyalty_programmes"], &parse_atom/1),
      supported_passenger_identity_document_types:
        parse_list(data["supported_passenger_identity_document_types"], &parse_atom/1),
      total_emissions_kg: data["total_emissions_kg"],
      live_mode: data["live_mode"],
      created_at: data["created_at"],
      updated_at: data["updated_at"]
    }
  end

  @doc """
  Parses a raw map into an `OfferPriced` struct.
  """
  @spec parse_offer_priced(map()) :: OfferPriced.t()
  def parse_offer_priced(data) do
    offer = parse_offer(data)

    %OfferPriced{
      id: offer.id,
      owner: offer.owner,
      total_amount: offer.total_amount,
      total_currency: offer.total_currency,
      base_amount: offer.base_amount,
      base_currency: offer.base_currency,
      tax_amount: offer.tax_amount,
      tax_currency: offer.tax_currency,
      expires_at: offer.expires_at,
      slices: offer.slices,
      passengers: offer.passengers,
      conditions: offer.conditions,
      available_services: offer.available_services,
      private_fares: offer.private_fares,
      payment_requirements: offer.payment_requirements,
      partial: offer.partial,
      supported_loyalty_programmes: offer.supported_loyalty_programmes,
      total_emissions_kg: offer.total_emissions_kg,
      live_mode: offer.live_mode,
      created_at: offer.created_at,
      updated_at: offer.updated_at,
      intended_payment_methods: data["intended_payment_methods"] || [],
      intended_services: data["intended_services"] || []
    }
  end

  @doc """
  Parses a raw map into an `OfferRequest` struct.
  """
  @spec parse_offer_request(map()) :: OfferRequest.t()
  def parse_offer_request(data) do
    %OfferRequest{
      id: data["id"],
      live_mode: data["live_mode"],
      created_at: data["created_at"],
      slices: parse_list(data["slices"], &parse_offer_request_slice/1),
      passengers: parse_list(data["passengers"], &parse_offer_request_passenger/1),
      cabin_class: parse_atom(data["cabin_class"]),
      max_connections: data["max_connections"],
      private_fares: parse_list(data["private_fares"], &parse_private_fare/1),
      offers: parse_list(data["offers"], &parse_offer/1)
    }
  end

  @doc """
  Parses a raw map into an `Order` struct.
  """
  @spec parse_order(map()) :: Order.t()
  def parse_order(data) do
    %Order{
      id: data["id"],
      booking_reference: data["booking_reference"],
      owner: data["owner"],
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      base_amount: data["base_amount"],
      base_currency: data["base_currency"],
      tax_amount: data["tax_amount"],
      tax_currency: data["tax_currency"],
      slices: parse_list(data["slices"], &parse_order_slice/1),
      services: parse_list(data["services"], &parse_order_service/1),
      passengers: parse_list(data["passengers"], &parse_order_passenger/1),
      payment_status: parse_payment_status(data["payment_status"]),
      live_mode: data["live_mode"],
      documents: data["documents"],
      created_at: data["created_at"],
      cancelled_at: data["cancelled_at"],
      conditions: data["conditions"],
      metadata: data["metadata"],
      airline_initiated_changes:
        parse_list(data["airline_initiated_changes"], &parse_airline_initiated_change/1),
      available_actions: parse_list(data["available_actions"], &parse_atom/1),
      synced_at: data["synced_at"],
      cancellation: parse_order_cancellation(data["cancellation"])
    }
  end

  @doc """
  Parses a raw map into an `OrderCancellation` struct.
  """
  @spec parse_order_cancellation(map() | nil) :: OrderCancellation.t() | nil
  def parse_order_cancellation(nil), do: nil

  def parse_order_cancellation(data) do
    %OrderCancellation{
      id: data["id"],
      order_id: data["order_id"],
      created_at: data["created_at"],
      confirmed_at: data["confirmed_at"],
      expires_at: data["expires_at"],
      live_mode: data["live_mode"],
      refund_amount: data["refund_amount"],
      refund_currency: data["refund_currency"],
      refund_to: parse_atom(data["refund_to"]),
      airline_credits:
        parse_list(data["airline_credits"], &parse_order_cancellation_airline_credit/1)
    }
  end

  @doc """
  Parses a raw map into an `OrderChangeOffer` struct.
  """
  @spec parse_order_change_offer(map()) :: OrderChangeOffer.t()
  def parse_order_change_offer(data) do
    %OrderChangeOffer{
      id: data["id"],
      order_id: data["order_id"],
      change_total_amount: data["change_total_amount"],
      change_total_currency: data["change_total_currency"],
      new_total_amount: data["new_total_amount"],
      new_total_currency: data["new_total_currency"],
      penalty_amount: data["penalty_amount"],
      penalty_currency: data["penalty_currency"],
      refund_to: parse_atom(data["refund_to"]),
      slices: parse_change_offer_slices(data["slices"]),
      expires_at: data["expires_at"],
      created_at: data["created_at"],
      updated_at: data["updated_at"],
      order_change_id: data["order_change_id"]
    }
  end

  @doc """
  Parses a raw map into an `OrderChange` struct.
  """
  @spec parse_order_change(map()) :: OrderChange.t()
  def parse_order_change(data) do
    %OrderChange{
      id: data["id"],
      order_id: data["order_id"],
      change_total_amount: data["change_total_amount"],
      change_total_currency: data["change_total_currency"],
      new_total_amount: data["new_total_amount"],
      new_total_currency: data["new_total_currency"],
      penalty_total_amount: data["penalty_total_amount"],
      penalty_total_currency: data["penalty_total_currency"],
      refund_to: parse_atom(data["refund_to"]),
      slices: parse_change_offer_slices(data["slices"]),
      expires_at: data["expires_at"],
      created_at: data["created_at"],
      confirmed_at: data["confirmed_at"],
      live_mode: data["live_mode"],
      available_payment_types: parse_list(data["available_payment_types"], &parse_atom/1)
    }
  end

  @doc """
  Parses a raw map into an `OrderChangeRequestResponse` struct.
  """
  @spec parse_order_change_request(map()) :: OrderChangeRequestResponse.t()
  def parse_order_change_request(data) do
    %OrderChangeRequestResponse{
      id: data["id"],
      order_id: data["order_id"],
      live_mode: data["live_mode"],
      slices: data["slices"],
      order_change_offers: parse_list(data["order_change_offers"], &parse_order_change_offer/1)
    }
  end

  @doc """
  Parses a raw map into a `BatchOfferRequest` struct.
  """
  @spec parse_batch_offer_request(map()) :: BatchOfferRequest.t()
  def parse_batch_offer_request(data) do
    %BatchOfferRequest{
      id: data["id"],
      created_at: data["created_at"],
      live_mode: data["live_mode"],
      client_key: data["client_key"],
      total_batches: data["total_batches"],
      remaining_batches: data["remaining_batches"],
      offers: parse_list(data["offers"], &parse_offer/1)
    }
  end

  @doc """
  Parses a raw map into a `CreateBatchOfferRequestResponse` struct.
  """
  @spec parse_create_batch_offer_request(map()) :: CreateBatchOfferRequestResponse.t()
  def parse_create_batch_offer_request(data) do
    %CreateBatchOfferRequestResponse{
      id: data["id"],
      created_at: data["created_at"],
      live_mode: data["live_mode"],
      client_key: data["client_key"],
      total_batches: data["total_batches"],
      remaining_batches: data["remaining_batches"]
    }
  end

  @doc """
  Parses a raw map into an `AirlineInitiatedChange` struct.
  """
  @spec parse_airline_initiated_change(map()) :: AirlineInitiatedChange.t()
  def parse_airline_initiated_change(data) do
    %AirlineInitiatedChange{
      id: data["id"],
      order_id: data["order_id"],
      action_taken: parse_atom(data["action_taken"]),
      action_taken_at: data["action_taken_at"],
      created_at: data["created_at"],
      updated_at: data["updated_at"],
      added: parse_list(data["added"], &parse_order_slice/1),
      removed: parse_list(data["removed"], &parse_order_slice/1),
      available_actions: parse_list(data["available_actions"], &parse_atom/1),
      travel_agent_ticket: parse_travel_agent_ticket(data["travel_agent_ticket"])
    }
  end

  @doc """
  Parses a raw map into a `SeatMap` struct.
  """
  @spec parse_seat_map(map()) :: SeatMap.t()
  def parse_seat_map(data) do
    %SeatMap{
      id: data["id"],
      slice_id: data["slice_id"],
      segment_id: data["segment_id"],
      cabins: parse_list(data["cabins"], &parse_seat_map_cabin/1)
    }
  end

  @doc """
  Parses a raw map into a `Payment` struct.
  """
  @spec parse_payment(map()) :: Payment.t()
  def parse_payment(data) do
    %Payment{
      id: data["id"],
      amount: data["amount"],
      currency: data["currency"],
      type: parse_atom(data["type"]),
      status: parse_atom(data["status"]),
      failure_reason: data["failure_reason"],
      order_id: data["order_id"],
      airline_credit_id: data["airline_credit_id"],
      live_mode: data["live_mode"],
      created_at: data["created_at"]
    }
  end

  @doc """
  Parses a raw map into an `AirlineCredit` struct.
  """
  @spec parse_airline_credit(map()) :: AirlineCredit.t()
  def parse_airline_credit(data) do
    %AirlineCredit{
      id: data["id"],
      order_id: data["order_id"],
      amount: data["amount"],
      currency: data["currency"],
      created_at: data["created_at"],
      live_mode: data["live_mode"]
    }
  end

  defp parse_offer_slice(data) do
    %OfferSlice{
      id: data["id"],
      origin_type: parse_atom(data["origin_type"]),
      destination_type: parse_atom(data["destination_type"]),
      origin: data["origin"],
      destination: data["destination"],
      duration: data["duration"],
      fare_brand_name: data["fare_brand_name"],
      segments: parse_list(data["segments"], &parse_offer_slice_segment/1),
      conditions: parse_slice_condition(data["conditions"]),
      ngs_shelf: data["ngs_shelf"]
    }
  end

  defp parse_offer_slice_segment(data) do
    %OfferSliceSegment{
      id: data["id"],
      origin: parse_place(data["origin"]),
      destination: parse_place(data["destination"]),
      departure_at: data["departing_at"],
      arriving_at: data["arriving_at"],
      duration: data["duration"],
      distance: data["distance"],
      marketing_carrier: data["marketing_carrier"],
      operating_carrier: data["operating_carrier"],
      marketing_carrier_flight_number: data["marketing_carrier_flight_number"],
      operating_carrier_flight_number: data["operating_carrier_flight_number"],
      origin_terminal: data["origin_terminal"],
      destination_terminal: data["destination_terminal"],
      aircraft: data["aircraft"],
      passengers: parse_list(data["passengers"], &parse_segment_passenger/1),
      stops: parse_list(data["stops"], &parse_segment_stop/1)
    }
  end

  defp parse_segment_passenger(data) do
    %OfferSliceSegmentPassenger{
      passenger_id: data["passenger_id"],
      cabin_class: parse_atom(data["cabin_class"]),
      cabin_class_marketing_name: data["cabin_class_marketing_name"],
      fare_basis_code: data["fare_basis_code"],
      baggages: parse_list(data["baggages"], &parse_baggage/1),
      cabin: data["cabin"]
    }
  end

  defp parse_baggage(data) do
    %OfferSliceSegmentPassengerBaggage{
      type: data["type"],
      quantity: data["quantity"]
    }
  end

  defp parse_segment_stop(data) do
    %OfferSliceSegmentStop{
      id: data["id"],
      duration: data["duration"],
      destination: parse_place(data["destination"])
    }
  end

  defp parse_offer_passenger(data) do
    %OfferPassenger{
      id: data["id"],
      age: data["age"],
      type: parse_atom(data["type"]),
      given_name: data["given_name"],
      family_name: data["family_name"],
      fare_type: parse_atom(data["fare_type"]),
      loyalty_programme_accounts: data["loyalty_programme_accounts"]
    }
  end

  def parse_available_service(data) do
    %OfferAvailableService{
      id: data["id"],
      type: parse_atom(data["type"]),
      passenger_ids: data["passenger_ids"],
      segment_ids: data["segment_ids"],
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      metadata: data["metadata"]
    }
  end

  defp parse_private_fare(data) do
    %OfferPrivateFare{
      type: parse_atom(data["type"]),
      corporate_code: data["corporate_code"],
      tracking_reference: data["tracking_reference"]
    }
  end

  defp parse_payment_requirements(nil), do: nil

  defp parse_payment_requirements(data) do
    %PaymentRequirements{
      payment_required_by: data["payment_required_by"],
      price_guarantee_expires_at: data["price_guarantee_expires_at"],
      requires_instant_payment: data["requires_instant_payment"]
    }
  end

  defp parse_offer_request_slice(data) do
    %OfferRequestSlice{
      origin_type: parse_atom(data["origin_type"]),
      destination_type: parse_atom(data["destination_type"]),
      origin: data["origin"],
      destination: data["destination"],
      departure_date: data["departure_date"]
    }
  end

  defp parse_offer_request_passenger(data) do
    %OfferRequestPassenger{
      id: data["id"],
      age: data["age"],
      type: parse_atom(data["type"]),
      given_name: data["given_name"],
      family_name: data["family_name"],
      loyalty_programme_accounts: data["loyalty_programme_accounts"]
    }
  end

  defp parse_order_slice(data) do
    %OrderSlice{
      id: data["id"],
      origin_type: parse_atom(data["origin_type"]),
      destination_type: parse_atom(data["destination_type"]),
      origin: data["origin"],
      destination: data["destination"],
      duration: data["duration"],
      fare_brand_name: data["fare_brand_name"],
      segments: parse_list(data["segments"], &parse_order_slice_segment/1),
      conditions: parse_slice_condition(data["conditions"]),
      ngs_shelf: data["ngs_shelf"]
    }
  end

  defp parse_order_slice_segment(data) do
    %OrderSliceSegment{
      id: data["id"],
      origin: parse_place(data["origin"]),
      destination: parse_place(data["destination"]),
      departure_at: data["departing_at"],
      arriving_at: data["arriving_at"],
      duration: data["duration"],
      distance: data["distance"],
      marketing_carrier: data["marketing_carrier"],
      operating_carrier: data["operating_carrier"],
      marketing_carrier_flight_number: data["marketing_carrier_flight_number"],
      operating_carrier_flight_number: data["operating_carrier_flight_number"],
      origin_terminal: data["origin_terminal"],
      destination_terminal: data["destination_terminal"],
      aircraft: data["aircraft"],
      passengers: parse_list(data["passengers"], &parse_order_segment_passenger/1),
      stops: parse_list(data["stops"], &parse_order_segment_stop/1)
    }
  end

  defp parse_order_segment_passenger(data) do
    %OrderSliceSegmentPassenger{
      passenger_id: data["passenger_id"],
      cabin_class: parse_atom(data["cabin_class"]),
      cabin_class_marketing_name: data["cabin_class_marketing_name"],
      fare_basis_code: data["fare_basis_code"],
      baggages: parse_list(data["baggages"], &parse_order_baggage/1),
      cabin: data["cabin"]
    }
  end

  defp parse_order_baggage(data) do
    %OrderSliceSegmentPassengerBaggage{
      type: data["type"],
      quantity: data["quantity"]
    }
  end

  defp parse_order_segment_stop(data) do
    %OrderSliceSegmentStop{
      id: data["id"],
      duration: data["duration"],
      destination: parse_place(data["destination"])
    }
  end

  defp parse_order_service(data) do
    %OrderService{
      id: data["id"],
      type: parse_atom(data["type"]),
      passenger_ids: data["passenger_ids"],
      segment_ids: data["segment_ids"],
      quantity: data["quantity"],
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      metadata: data["metadata"]
    }
  end

  defp parse_order_passenger(data) do
    %OrderPassenger{
      id: data["id"],
      born_on: data["born_on"],
      family_name: data["family_name"],
      given_name: data["given_name"],
      gender: parse_atom(data["gender"]),
      title: parse_atom(data["title"]),
      type: parse_atom(data["type"]),
      email: data["email"],
      phone_number: data["phone_number"],
      infant_passenger_id: data["infant_passenger_id"],
      loyalty_programme_accounts: data["loyalty_programme_accounts"]
    }
  end

  defp parse_payment_status(nil), do: nil

  defp parse_payment_status(data) do
    %OrderPaymentStatus{
      awaiting_payment: data["awaiting_payment"],
      payment_required_by: data["payment_required_by"],
      price_guarantee_expires_at: data["price_guarantee_expires_at"],
      paid_at: data["paid_at"]
    }
  end

  defp parse_order_cancellation_airline_credit(data) do
    %OrderCancellationAirlineCredit{
      id: data["id"],
      credit_name: data["credit_name"],
      credit_code: data["credit_code"],
      credit_amount: data["credit_amount"],
      credit_currency: data["credit_currency"],
      issued_on: data["issued_on"],
      passenger_id: data["passenger_id"]
    }
  end

  defp parse_change_offer_slices(nil), do: %OrderChangeOfferSlices{add: [], remove: []}

  defp parse_change_offer_slices(data) do
    %OrderChangeOfferSlices{
      add: parse_list(data["add"], &parse_change_offer_slice/1),
      remove: parse_list(data["remove"], &parse_change_offer_slice/1)
    }
  end

  defp parse_change_offer_slice(data) do
    %OrderChangeOfferSlice{
      id: data["id"],
      origin_type: parse_atom(data["origin_type"]),
      destination_type: parse_atom(data["destination_type"]),
      origin: data["origin"],
      destination: data["destination"],
      duration: data["duration"],
      fare_brand_name: data["fare_brand_name"],
      segments: parse_list(data["segments"], &parse_offer_slice_segment/1)
    }
  end

  defp parse_travel_agent_ticket(nil), do: nil

  defp parse_travel_agent_ticket(data) do
    %TravelAgentTicket{
      id: data["id"],
      external_ticket_id: data["external_ticket_id"]
    }
  end

  defp parse_seat_map_cabin(data) do
    %SeatMapCabin{
      deck: data["deck"],
      cabin_class: parse_atom(data["cabin_class"]),
      wings: parse_list(data["wings"], &parse_wing/1),
      aisles: data["aisles"],
      rows: parse_list(data["rows"], &parse_seat_map_row/1)
    }
  end

  defp parse_wing(data) do
    %SeatMapCabinWing{rows: data["rows"]}
  end

  defp parse_seat_map_row(data) do
    %SeatMapCabinRow{
      sections: parse_list(data["sections"], &parse_seat_map_section/1)
    }
  end

  defp parse_seat_map_section(data) do
    %SeatMapCabinRowSection{
      elements: parse_list(data["elements"], &parse_seat_map_element/1)
    }
  end

  defp parse_seat_map_element(data) do
    %SeatMapCabinRowSectionElement{
      type: parse_atom(data["type"]),
      designator: data["designator"],
      name: data["name"],
      disclosures: data["disclosures"] || [],
      available_services: data["available_services"] || []
    }
  end

  defp parse_place(nil), do: nil

  defp parse_place(%{"type" => "airport"} = data) do
    %PlaceAirport{
      type: :airport,
      id: data["id"],
      name: data["name"],
      time_zone: data["time_zone"],
      iata_code: data["iata_code"],
      iata_country_code: data["iata_country_code"],
      city_name: data["city_name"],
      city: data["city"],
      country: data["country"]
    }
  end

  defp parse_place(%{"type" => "city"} = data) do
    %PlaceCity{
      type: :city,
      id: data["id"],
      name: data["name"],
      iata_code: data["iata_code"],
      iata_country_code: data["iata_country_code"],
      airports: data["airports"],
      country: data["country"]
    }
  end

  defp parse_slice_condition(nil), do: %OfferSliceCondition{}

  defp parse_slice_condition(data) do
    %OfferSliceCondition{
      change_before_departure: data["change_before_departure"],
      refund_before_departure: data["refund_before_departure"],
      advance_seat_selection: data["advance_seat_selection"],
      priority_boarding: data["priority_boarding"],
      priority_check_in: data["priority_check_in"]
    }
  end

  defp parse_list(nil, _parser), do: []
  defp parse_list(data, parser) when is_list(data), do: Enum.map(data, parser)

  defp parse_atom(nil), do: nil
  defp parse_atom(string) when is_binary(string), do: String.to_atom(string)
  defp parse_atom(atom) when is_atom(atom), do: atom
end
