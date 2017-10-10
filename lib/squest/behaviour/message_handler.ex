defmodule Squest.Behaviour.MessageHandler do
  alias Squest.SQS.Message
  @type result :: :ok | :error

  @callback handle_message(sqs_message :: Message.t) :: __MODULE__.result
end
