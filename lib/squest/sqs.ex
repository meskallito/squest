defmodule Squest.SQS do

  alias Squest.SQS.Message

  @receive_max_message_count 10
  @aws_backend :erlcloud_sqs
  @request_sqs_attributes [:approximate_first_receive_timestamp, :approximate_receive_count]

  def receive_messages(queue_name, number) do
    @aws_backend.receive_message(
      queue_name, @request_sqs_attributes, Enum.min([number, @receive_max_message_count])
    ) |> Keyword.fetch!(:messages) |> Enum.map(fn message_attrs ->
      Message.new(queue_name, message_attrs)
    end)
  end

  def delete_message(queue_name, receipt_handle) do
    @aws_backend.delete_message(queue_name |> to_charlist, receipt_handle |> to_charlist)
  end

  def queue_exists?(queue_name) do
    @aws_backend.list_queues()
    |> Enum.any?(fn queue_path ->
      Regex.match?(~r/\/#{queue_name}$/, to_string(queue_path))
    end)
  end

  def change_message_visibility(queue_name, receipt_handle, visibility_timeout) do
    @aws_backend.change_message_visibility(queue_name, receipt_handle, visibility_timeout)
  end
end
