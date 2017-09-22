defmodule Squest.MessageHandlerBehaviour do
  alias Squest.SQS.Message
  @type result :: :ok | :error

  @callback handle_message(sqs_message :: Message.t) :: MessageHandlerBehaviour.result
end
