defmodule Squest.ExponentialBackoff do
  @behaviour Squest.Behaviour.RetryStrategy

  require Logger
  import Squest.SQS, only: [change_message_visibility: 3]

  def schedule_retry(sqs_message) do
    attempts = sqs_message.attributes[:approximate_receive_count]
    started_at = sqs_message.attributes[:approximate_first_receive_timestamp]

    #getting interval based on the approximate number of times message was received
    interval = :math.pow(2, attempts) |> round

    #the maximum visibility timeout is 12h
    max_timeout = 43200 - round((:os.system_time(:milli_seconds) - started_at)/1000)

    change_message_visibility(
      sqs_message.__queue_name__,
      sqs_message.receipt_handle,
      Enum.min([max_timeout, interval])
    ) |> check_success(sqs_message)
  end

  defp check_success(:ok, _), do: :ok
  defp check_success(e, sqs_message) do
    Logger.error("Message #{inspect(sqs_message)} can't be rescheduled: #{inspect(e)}")
  end
end
