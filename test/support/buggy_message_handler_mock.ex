defmodule BuggyMessageHandlerMock do
  use Squest.MessageHandler
  require Logger

  def handle_message(_message) do
    raise "Buggy message handler raised an error"
  end
end
