defmodule Squest.TestHandler do
  use Squest.MessageHandler
  require Logger

  def handle_message(sqs_message) do
    Logger.debug("Processing in the handler #{inspect(sqs_message)}")
  end
end
