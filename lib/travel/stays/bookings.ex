defmodule Travel.Stays.Bookings do
  @moduledoc """
  Create, retrieve, list, and cancel bookings.

  ## Endpoints

    * `POST /stays/bookings` - Create a booking
    * `GET /stays/bookings/{id}` - Get a booking
    * `GET /stays/bookings` - List bookings
    * `PATCH /stays/bookings/{id}` - Update a booking
    * `POST /stays/bookings/{id}/actions/cancel` - Cancel a booking

  ## Examples

      # Create a booking
      {:ok, response} = Travel.Stays.Bookings.create(%{
        quote_id: "quo_123",
        guests: [%{given_name: "John", family_name: "Smith"}],
        email: "john@example.com",
        phone_number: "+447700900000"
      })

      # Get a booking
      {:ok, response} = Travel.Stays.Bookings.get("bok_123")

      # List bookings
      {:ok, response} = Travel.Stays.Bookings.list(%{limit: 20})

      # Cancel a booking
      {:ok, response} = Travel.Stays.Bookings.cancel("bok_123")

  @link https://duffel.com/docs/api/stays/bookings
  """

  alias Travel.Client
  alias Travel.Stays.Types

  @doc """
  Create a booking.

  ## Parameters

    * `params` - Booking parameters:
      * `:quote_id` - (required) The quote ID to book
      * `:guests` - (required) List of guests with `given_name` and `family_name`
      * `:email` - (required) Lead guest email
      * `:phone_number` - (required) Lead guest phone number
      * `:loyalty_programme_account_number` - (optional) Loyalty account number
      * `:accommodation_special_requests` - (optional) Special requests
      * `:payment` - (optional) Payment info
      * `:metadata` - (optional) Custom metadata map
      * `:users` - (optional) List of user IDs allowed to manage the booking

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysBooking{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(params) do
    config = Travel.config!()

    case Client.request(config, :post, "stays/bookings", params) do
      {:ok, response} ->
        parsed_data = Types.parse_booking(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a booking by ID.

  ## Parameters

    * `booking_id` - The booking ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysBooking{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec get(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def get(booking_id) do
    config = Travel.config!()

    case Client.request(config, :get, "stays/bookings/#{booking_id}") do
      {:ok, response} ->
        parsed_data = Types.parse_booking(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List bookings with optional filtering and pagination.

  ## Parameters

    * `opts` - Optional query parameters:
      * `:limit` - Results per page (max 200)
      * `:before` - Cursor for previous page
      * `:after` - Cursor for next page
      * `:user_id` - Filter by customer user ID

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: [%Types.StaysBooking{}]}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec list(map() | nil) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def list(opts \\ nil) do
    config = Travel.config!()

    case Client.request(config, :get, "stays/bookings", nil, opts) do
      {:ok, response} ->
        parsed_data = Enum.map(response.data, &Types.parse_booking/1)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  List all bookings as a stream, handling pagination automatically.

  ## Parameters

    * `opts` - Optional query parameters (e.g., `user_id`)

  ## Returns

    A `Stream` that yields `%Travel.Types.DuffelResponse{}` for each page.

  """
  @spec stream(map() | nil) :: Enumerable.t()
  def stream(opts \\ nil) do
    config = Travel.config!()

    Client.stream(config, "stays/bookings", opts)
    |> Stream.map(fn response ->
      parsed_data = Enum.map(response.data, &Types.parse_booking/1)
      %{response | data: parsed_data}
    end)
  end

  @doc """
  Update a booking.

  ## Parameters

    * `booking_id` - The booking ID
    * `params` - Update parameters:
      * `:users` - (required) List of user IDs allowed to manage the booking

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysBooking{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec update(String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def update(booking_id, params) do
    config = Travel.config!()

    case Client.request(config, :patch, "stays/bookings/#{booking_id}", params) do
      {:ok, response} ->
        parsed_data = Types.parse_booking(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Cancel a booking.

  ## Parameters

    * `booking_id` - The booking ID to cancel

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: %Types.StaysBooking{}}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec cancel(String.t()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def cancel(booking_id) do
    config = Travel.config!()
    path = "stays/bookings/#{booking_id}/actions/cancel"

    case Client.request(config, :post, path) do
      {:ok, response} ->
        parsed_data = Types.parse_booking(response.data)
        {:ok, %{response | data: parsed_data}}

      {:error, error} ->
        {:error, error}
    end
  end
end
