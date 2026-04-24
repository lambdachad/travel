defmodule Travel.Stays.Types do
  @moduledoc """
  Types for the Duffel Stays API.
  """

  use TypedStruct

  typedstruct module: StaysBed do
    field(:type, atom())
    field(:count, integer())
  end

  typedstruct module: StaysPhoto do
    field(:url, String.t())
  end

  typedstruct module: StaysRating do
    field(:source, String.t())
    field(:value, integer())
  end

  typedstruct module: StaysRateCondition do
    field(:title, String.t())
    field(:description, String.t())
  end

  typedstruct module: StaysRateCancellationTimeline do
    field(:before, String.t())
    field(:refund_amount, String.t())
    field(:currency, String.t())
  end

  typedstruct module: StaysRate do
    field(:id, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:fee_amount, String.t() | nil)
    field(:fee_currency, String.t())
    field(:due_at_accommodation_amount, String.t() | nil)
    field(:due_at_accommodation_currency, String.t())
    field(:board_type, atom())
    field(:payment_type, atom())
    field(:available_payment_methods, list(atom()))
    field(:conditions, list(StaysRateCondition.t()))
    field(:cancellation_timeline, list(StaysRateCancellationTimeline.t()))
    field(:supported_loyalty_programme, atom() | nil)
    field(:loyalty_programme_required, boolean(), default: false)
    field(:source, atom())
    field(:expires_at, String.t())
    field(:code, String.t() | nil)
    field(:description, String.t() | nil)
    field(:name, String.t() | nil)
    field(:estimated_commission_amount, String.t() | nil)
    field(:estimated_commission_currency, String.t() | nil)
  end

  typedstruct module: StaysRoomRate do
    field(:id, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:fee_amount, String.t() | nil)
    field(:fee_currency, String.t())
    field(:due_at_accommodation_amount, String.t() | nil)
    field(:due_at_accommodation_currency, String.t())
    field(:board_type, atom())
    field(:payment_type, atom())
    field(:available_payment_methods, list(atom()))
    field(:conditions, list(StaysRateCondition.t()))
    field(:cancellation_timeline, list(StaysRateCancellationTimeline.t()))
    field(:supported_loyalty_programme, atom() | nil)
    field(:loyalty_programme_required, boolean(), default: false)
    field(:source, atom())
    field(:expires_at, String.t())
    field(:code, String.t() | nil)
    field(:description, String.t() | nil)
    field(:name, String.t() | nil)
    field(:estimated_commission_amount, String.t() | nil)
    field(:estimated_commission_currency, String.t() | nil)
    field(:quantity_available, integer() | nil)
  end

  typedstruct module: StaysRoom do
    field(:name, String.t())
    field(:beds, list(StaysBed.t()) | nil)
    field(:photos, list(StaysPhoto.t()) | nil)
    field(:rates, list(StaysRoomRate.t()))
  end

  typedstruct module: StaysAmenity do
    field(:type, atom())
    field(:description, String.t())
  end

  typedstruct module: StaysChain do
    field(:name, String.t())
  end

  typedstruct module: StaysAddress do
    field(:city_name, String.t())
    field(:country_code, String.t())
    field(:line_one, String.t())
    field(:postal_code, String.t())
    field(:region, String.t() | nil)
  end

  typedstruct module: GeographicCoordinates do
    field(:latitude, float())
    field(:longitude, float())
  end

  typedstruct module: StaysLocation do
    field(:address, StaysAddress.t())
    field(:geographic_coordinates, GeographicCoordinates.t() | nil)
  end

  typedstruct module: StaysAccommodationBrand do
    field(:id, String.t())
    field(:name, String.t())
  end

  typedstruct module: StaysAccommodation do
    field(:id, String.t())
    field(:name, String.t())
    field(:description, String.t() | nil)
    field(:email, String.t() | nil)
    field(:phone_number, String.t() | nil)
    field(:location, StaysLocation.t())
    field(:chain, StaysChain.t() | nil)
    field(:brand, StaysAccommodationBrand.t() | nil)
    field(:amenities, list(StaysAmenity.t()) | nil)
    field(:rooms, list(StaysRoom.t()))
    field(:photos, list(StaysPhoto.t()) | nil)
    field(:ratings, list(StaysRating.t()) | nil)
    field(:rating, integer() | nil)
    field(:review_count, integer() | nil)
    field(:review_score, float() | nil)
    field(:supported_loyalty_programme, atom() | nil)

    field(
      :check_in_information,
      %{check_in_after_time: String.t(), check_out_before_time: String.t()} | nil
    )

    field(:key_collection, StaysBookingKeyCollection.t() | nil)
  end

  typedstruct module: StaysAccommodationSuggestion do
    field(:accommodation_id, String.t())
    field(:accommodation_name, String.t())
    field(:accommodation_location, StaysLocation.t())
  end

  typedstruct module: StaysQuote do
    field(:id, String.t())
    field(:check_in_date, String.t())
    field(:check_out_date, String.t())
    field(:accommodation, StaysAccommodation.t())
    field(:total_amount, String.t())
    field(:total_currency, String.t())
    field(:base_amount, String.t() | nil)
    field(:base_currency, String.t())
    field(:fee_amount, String.t() | nil)
    field(:fee_currency, String.t())
    field(:tax_amount, String.t() | nil)
    field(:tax_currency, String.t())
    field(:due_at_accommodation_amount, String.t() | nil)
    field(:due_at_accommodation_currency, String.t())
    field(:deposit_amount, String.t() | nil)
    field(:deposit_currency, String.t())
    field(:supported_loyalty_programme, atom() | nil)
    field(:rooms, integer())
    field(:guests, list(map()))
  end

  typedstruct module: StaysBookingKeyCollection do
    field(:instructions, String.t())
  end

  typedstruct module: StaysBooking do
    field(:id, String.t())
    field(:email, String.t())
    field(:phone_number, String.t())
    field(:accommodation, StaysAccommodation.t())
    field(:check_in_date, String.t())
    field(:check_out_date, String.t())
    field(:reference, String.t() | nil)
    field(:status, atom())
    field(:confirmed_at, String.t())
    field(:cancelled_at, String.t() | nil)
    field(:guests, list(%{given_name: String.t(), family_name: String.t()}))
    field(:supported_loyalty_programme, atom() | nil)
    field(:loyalty_programme_account_number, String.t() | nil)
    field(:rooms, integer())
    field(:metadata, map() | nil)
    field(:key_collection, StaysBookingKeyCollection.t() | nil)
    field(:estimated_commission_amount, String.t() | nil)
    field(:estimated_commission_currency, String.t() | nil)
  end

  typedstruct module: StaysSearchResult do
    field(:id, String.t())
    field(:check_in_date, String.t())
    field(:check_out_date, String.t())
    field(:accommodation, StaysAccommodation.t())
    field(:rooms, integer())
    field(:guests, list(map()))
    field(:cheapest_rate_total_amount, String.t())
    field(:cheapest_rate_currency, String.t())
    field(:cheapest_rate_base_amount, String.t() | nil)
    field(:cheapest_rate_base_currency, String.t())
    field(:cheapest_rate_public_amount, String.t() | nil)
    field(:cheapest_rate_public_currency, String.t())
    field(:cheapest_rate_due_at_accommodation_amount, String.t() | nil)
    field(:cheapest_rate_due_at_accommodation_currency, String.t())
    field(:expires_at, String.t())
  end

  typedstruct module: StaysSearchResponse do
    field(:results, list(StaysSearchResult.t()))
    field(:created_at, String.t())
  end

  typedstruct module: StaysLoyaltyProgramme do
    field(:reference, atom())
    field(:name, String.t())
    field(:logo_url_svg, String.t())
    field(:logo_url_png_small, String.t())
  end

  typedstruct module: StaysAccommodationReview do
    field(:created_at, String.t())
    field(:reviewer_name, String.t())
    field(:score, float())
    field(:text, String.t())
  end

  typedstruct module: StaysAccommodationReviewResponse do
    field(:reviews, list(StaysAccommodationReview.t()))
  end

  @doc """
  Parses a raw map into a `StaysAccommodation` struct.
  """
  @spec parse_accommodation(map()) :: StaysAccommodation.t()
  def parse_accommodation(data) do
    %StaysAccommodation{
      id: data["id"],
      name: data["name"],
      description: data["description"],
      email: data["email"],
      phone_number: data["phone_number"],
      location: parse_location(data["location"]),
      chain: parse_chain(data["chain"]),
      brand: parse_brand(data["brand"]),
      amenities: parse_list(data["amenities"], &parse_amenity/1),
      rooms: parse_list(data["rooms"], &parse_room/1),
      photos: parse_list(data["photos"], &parse_photo/1),
      ratings: parse_list(data["ratings"], &parse_rating/1),
      rating: data["rating"],
      review_count: data["review_count"],
      review_score: data["review_score"],
      supported_loyalty_programme: parse_atom(data["supported_loyalty_programme"]),
      check_in_information: parse_check_in_info(data["check_in_information"]),
      key_collection: parse_key_collection(data["key_collection"])
    }
  end

  @doc """
  Parses a raw map into a `StaysQuote` struct.
  """
  @spec parse_quote(map()) :: StaysQuote.t()
  def parse_quote(data) do
    %StaysQuote{
      id: data["id"],
      check_in_date: data["check_in_date"],
      check_out_date: data["check_out_date"],
      accommodation: parse_accommodation(data["accommodation"]),
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      base_amount: data["base_amount"],
      base_currency: data["base_currency"],
      fee_amount: data["fee_amount"],
      fee_currency: data["fee_currency"],
      tax_amount: data["tax_amount"],
      tax_currency: data["tax_currency"],
      due_at_accommodation_amount: data["due_at_accommodation_amount"],
      due_at_accommodation_currency: data["due_at_accommodation_currency"],
      deposit_amount: data["deposit_amount"],
      deposit_currency: data["deposit_currency"],
      supported_loyalty_programme: parse_atom(data["supported_loyalty_programme"]),
      rooms: data["rooms"],
      guests: parse_list(data["guests"], &parse_guest/1)
    }
  end

  @doc """
  Parses a raw map into a `StaysBooking` struct.
  """
  @spec parse_booking(map()) :: StaysBooking.t()
  def parse_booking(data) do
    %StaysBooking{
      id: data["id"],
      email: data["email"],
      phone_number: data["phone_number"],
      accommodation: parse_accommodation(data["accommodation"]),
      check_in_date: data["check_in_date"],
      check_out_date: data["check_out_date"],
      reference: data["reference"],
      status: parse_atom(data["status"]),
      confirmed_at: data["confirmed_at"],
      cancelled_at: data["cancelled_at"],
      guests: parse_list(data["guests"], &parse_booking_guest/1),
      supported_loyalty_programme: parse_atom(data["supported_loyalty_programme"]),
      loyalty_programme_account_number: data["loyalty_programme_account_number"],
      rooms: data["rooms"],
      metadata: data["metadata"],
      key_collection: parse_key_collection(data["key_collection"]),
      estimated_commission_amount: data["estimated_commission_amount"],
      estimated_commission_currency: data["estimated_commission_currency"]
    }
  end

  @doc """
  Parses a raw map into a `StaysSearchResponse` struct.
  """
  @spec parse_search_response(map()) :: StaysSearchResponse.t()
  def parse_search_response(data) do
    %StaysSearchResponse{
      results: parse_list(data["results"], &parse_search_result/1),
      created_at: data["created_at"]
    }
  end

  @doc """
  Parses a raw map into a `StaysSearchResult` struct.
  """
  @spec parse_search_result(map()) :: StaysSearchResult.t()
  def parse_search_result(data) do
    %StaysSearchResult{
      id: data["id"],
      check_in_date: data["check_in_date"],
      check_out_date: data["check_out_date"],
      accommodation: parse_accommodation(data["accommodation"]),
      rooms: data["rooms"],
      guests: parse_list(data["guests"], &parse_guest/1),
      cheapest_rate_total_amount: data["cheapest_rate_total_amount"],
      cheapest_rate_currency: data["cheapest_rate_currency"],
      cheapest_rate_base_amount: data["cheapest_rate_base_amount"],
      cheapest_rate_base_currency: data["cheapest_rate_base_currency"],
      cheapest_rate_public_amount: data["cheapest_rate_public_amount"],
      cheapest_rate_public_currency: data["cheapest_rate_public_currency"],
      cheapest_rate_due_at_accommodation_amount:
        data["cheapest_rate_due_at_accommodation_amount"],
      cheapest_rate_due_at_accommodation_currency:
        data["cheapest_rate_due_at_accommodation_currency"],
      expires_at: data["expires_at"]
    }
  end

  @doc """
  Parses a raw map into a `StaysAccommodationSuggestion` struct.
  """
  @spec parse_accommodation_suggestion(map()) :: StaysAccommodationSuggestion.t()
  def parse_accommodation_suggestion(data) do
    %StaysAccommodationSuggestion{
      accommodation_id: data["accommodation_id"],
      accommodation_name: data["accommodation_name"],
      accommodation_location: parse_location(data["accommodation_location"])
    }
  end

  @doc """
  Parses a raw map into a `StaysLoyaltyProgramme` struct.
  """
  @spec parse_loyalty_programme(map()) :: StaysLoyaltyProgramme.t()
  def parse_loyalty_programme(data) do
    %StaysLoyaltyProgramme{
      reference: parse_atom(data["reference"]),
      name: data["name"],
      logo_url_svg: data["logo_url_svg"],
      logo_url_png_small: data["logo_url_png_small"]
    }
  end

  @doc """
  Parses a raw map into a `StaysAccommodationReviewResponse` struct.
  """
  @spec parse_review_response(map()) :: StaysAccommodationReviewResponse.t()
  def parse_review_response(data) do
    %StaysAccommodationReviewResponse{
      reviews: parse_list(data["reviews"], &parse_review/1)
    }
  end

  defp parse_location(nil), do: nil

  defp parse_location(data) do
    %StaysLocation{
      address: parse_address(data["address"]),
      geographic_coordinates: parse_geographic_coordinates(data["geographic_coordinates"])
    }
  end

  defp parse_address(nil), do: nil

  defp parse_address(data) do
    %StaysAddress{
      city_name: data["city_name"],
      country_code: data["country_code"],
      line_one: data["line_one"],
      postal_code: data["postal_code"],
      region: data["region"]
    }
  end

  defp parse_geographic_coordinates(nil), do: nil

  defp parse_geographic_coordinates(data) do
    %GeographicCoordinates{
      latitude: data["latitude"],
      longitude: data["longitude"]
    }
  end

  defp parse_chain(nil), do: nil

  defp parse_chain(data) do
    %StaysChain{name: data["name"]}
  end

  defp parse_brand(nil), do: nil

  defp parse_brand(data) do
    %StaysAccommodationBrand{
      id: data["id"],
      name: data["name"]
    }
  end

  defp parse_amenity(data) do
    %StaysAmenity{
      type: parse_atom(data["type"]),
      description: data["description"]
    }
  end

  defp parse_room(data) do
    %StaysRoom{
      name: data["name"],
      beds: parse_list(data["beds"], &parse_bed/1),
      photos: parse_list(data["photos"], &parse_photo/1),
      rates: parse_list(data["rates"], &parse_room_rate/1)
    }
  end

  defp parse_bed(data) do
    %StaysBed{
      type: parse_atom(data["type"]),
      count: data["count"]
    }
  end

  defp parse_photo(data) do
    %StaysPhoto{url: data["url"]}
  end

  defp parse_rating(data) do
    %StaysRating{
      source: data["source"],
      value: data["value"]
    }
  end

  defp parse_room_rate(data) do
    %StaysRoomRate{
      id: data["id"],
      base_amount: data["base_amount"],
      base_currency: data["base_currency"],
      total_amount: data["total_amount"],
      total_currency: data["total_currency"],
      tax_amount: data["tax_amount"],
      tax_currency: data["tax_currency"],
      fee_amount: data["fee_amount"],
      fee_currency: data["fee_currency"],
      due_at_accommodation_amount: data["due_at_accommodation_amount"],
      due_at_accommodation_currency: data["due_at_accommodation_currency"],
      board_type: parse_atom(data["board_type"]),
      payment_type: parse_atom(data["payment_type"]),
      available_payment_methods: parse_list(data["available_payment_methods"], &parse_atom/1),
      conditions: parse_list(data["conditions"], &parse_rate_condition/1),
      cancellation_timeline:
        parse_list(data["cancellation_timeline"], &parse_cancellation_timeline/1),
      supported_loyalty_programme: parse_atom(data["supported_loyalty_programme"]),
      loyalty_programme_required: data["loyalty_programme_required"] || false,
      source: parse_atom(data["source"]),
      expires_at: data["expires_at"],
      code: data["code"],
      description: data["description"],
      name: data["name"],
      estimated_commission_amount: data["estimated_commission_amount"],
      estimated_commission_currency: data["estimated_commission_currency"],
      quantity_available: data["quantity_available"]
    }
  end

  defp parse_rate_condition(data) do
    %StaysRateCondition{
      title: data["title"],
      description: data["description"]
    }
  end

  defp parse_cancellation_timeline(data) do
    %StaysRateCancellationTimeline{
      before: data["before"],
      refund_amount: data["refund_amount"],
      currency: data["currency"]
    }
  end

  defp parse_check_in_info(nil), do: nil

  defp parse_check_in_info(data) do
    %{
      check_in_after_time: data["check_in_after_time"],
      check_out_before_time: data["check_out_before_time"]
    }
  end

  defp parse_key_collection(nil), do: nil

  defp parse_key_collection(data) do
    %StaysBookingKeyCollection{instructions: data["instructions"]}
  end

  defp parse_guest(data) do
    %{type: parse_atom(data["type"]), age: data["age"]}
  end

  defp parse_booking_guest(data) do
    %{given_name: data["given_name"], family_name: data["family_name"]}
  end

  defp parse_review(data) do
    %StaysAccommodationReview{
      created_at: data["created_at"],
      reviewer_name: data["reviewer_name"],
      score: data["score"],
      text: data["text"]
    }
  end

  defp parse_list(nil, _parser), do: []
  defp parse_list(data, parser) when is_list(data), do: Enum.map(data, parser)

  defp parse_atom(nil), do: nil
  defp parse_atom(string) when is_binary(string), do: String.to_atom(string)
  defp parse_atom(atom) when is_atom(atom), do: atom
end
