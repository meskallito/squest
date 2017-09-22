defmodule Squest.Pipeline.MessageConsumer do

  import Squest.SQS, only: [delete_message: 2]

  require Logger
  require IEx

  def start_link(message_handler, retry_strategy, sqs_message) do
    Task.start_link(fn ->
      try do
        message_handler.handle_message(sqs_message)
        delete_message(
          sqs_message.__queue_name__,
          sqs_message.receipt_handle
        )
      rescue
        e ->
          Logger.error(Exception.message(e))
          retry_strategy.schedule_retry(sqs_message)
      end
    end)
  end
end
