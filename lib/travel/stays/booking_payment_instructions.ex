defmodule Travel.Stays.BookingPaymentInstructions do
  @moduledoc """
  Create booking payment instructions.

  This is a Preview endpoint.

  ## Endpoints

    * `POST /stays/bookings/{booking_id}/payment_instructions` - Create a booking payment instruction

  ## Examples

      config = Travel.new(access_token: "duffel_test_xxx")

      {:ok, response} = Travel.Stays.BookingPaymentInstructions.create(config, "bok_123", %{
        card_id: "tcd_123"
      })

  @link https://duffel.com/docs/api/v2/booking-payment-instructions
  """

  alias Travel.Client

  @doc """
  Create a booking payment instruction.

  ## Parameters

    * `config` - Travel configuration
    * `booking_id` - The booking ID
    * `params` - Payment instruction parameters:
      * `:card_id` - (required) The card ID to use for payment

  ## Returns

    * `{:ok, %Travel.Types.DuffelResponse{data: map()}}` on success
    * `{:error, %Travel.Error{}}` on failure

  """
  @spec create(Travel.t(), String.t(), map()) ::
          {:ok, Travel.Types.DuffelResponse.t()} | {:error, Travel.Error.t() | term()}
  def create(config, booking_id, params) do
    Client.request(config, :post, "stays/bookings/#{booking_id}/payment_instructions", params)
  end
end
