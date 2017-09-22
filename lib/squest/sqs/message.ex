defmodule Squest.SQS.Message do
  @type t :: %__MODULE__{
    body: String.t,
    md5_of_body: String.t,
    message_id: String.t,
    receipt_handle: String.t,
    attributes: Keyword.t,
    message_attributes: Keyword.t,
    __queue_name__: String.t
  }
  @enforce_keys [
    :body,
    :md5_of_body,
    :message_id,
    :receipt_handle,
    :attributes,
    :message_attributes,
    :__queue_name__
  ]
  defstruct @enforce_keys

  def new(queue_name, message_attrs) do
    struct(
      __MODULE__,
      cast_message_attributes(message_attrs) |> put_in([:__queue_name__], queue_name)
    )
  end

  def cast_message_attributes(message_attrs) do
    message_attrs
    |> stringify_keys([:body, :md5_of_body, :message_id, :receipt_handle])
  end

  defp stringify_keys(message_attrs, keys) do
    Enum.reduce(
      keys,
      message_attrs,
      &stringify_value/2
    )
  end

  defp stringify_value(attribute_name, message_attrs) do
    Keyword.update!(message_attrs, attribute_name, &(&1 |> to_string))
  end
end

