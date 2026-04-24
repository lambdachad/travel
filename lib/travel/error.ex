defmodule Travel.Error do
  @moduledoc """
  Represents an error response from the Duffel API.

  ## Fields

    * `:status` - HTTP status code
    * `:request_id` - Unique request identifier from Duffel
    * `:code` - Error code string
    * `:message` - Human-readable error message
    * `:title` - Short error title
    * `:type` - Error type classification
    * `:documentation_url` - Link to relevant documentation
  """

  use TypedStruct

  typedstruct enforce: true do
    field(:status, integer())
    field(:request_id, String.t())
    field(:code, String.t())
    field(:message, String.t())
    field(:title, String.t())
    field(:type, String.t())
    field(:documentation_url, String.t())
  end

  defimpl String.Chars do
    def to_string(%Travel.Error{message: message, code: code}) do
      "[#{code}] #{message}"
    end
  end

  @doc """
  Parses an API error response into a `Travel.Error` struct.

  ## Examples

      iex> body = %{
      ...>   "meta" => %{"request_id" => "req_123"},
      ...>   "errors" => [%{
      ...>         "code" => "invalid_request",
      ...>         "message" => "Invalid parameter",
      ...>         "title" => "Invalid Request",
      ...>         "type" => "validation_error",
      ...>         "documentation_url" => "https://duffel.com/docs/api/errors"
      ...>       }]
      ...> }
      iex> Travel.Error.from_response(body, 400)
      %Travel.Error{
        status: 400,
        request_id: "req_123",
        code: "invalid_request",
        message: "Invalid parameter",
        title: "Invalid Request",
        type: "validation_error",
        documentation_url: "https://duffel.com/docs/api/errors"
      }

  """
  @spec from_response(map(), integer()) :: t()
  def from_response(body, status) do
    meta = body["meta"] || %{}
    error = List.first(body["errors"] || [])

    %__MODULE__{
      status: status,
      request_id: meta["request_id"] || "",
      code: error["code"] || "unknown",
      message: error["message"] || "An unknown error occurred",
      title: error["title"] || "",
      type: error["type"] || "",
      documentation_url: error["documentation_url"] || ""
    }
  end
end
