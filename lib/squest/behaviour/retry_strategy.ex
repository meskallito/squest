defmodule Squest.Behaviour.RetryStrategy do
  alias Squest.SQS.Message
  @type result :: :ok | :error

  @callback schedule_retry(sqs_message :: Message.t) :: any
end
