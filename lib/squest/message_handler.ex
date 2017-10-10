defmodule Squest.MessageHandler do
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(Squest.MessageHandlerBehaviour)
    end
  end

  def valid_message_handler?(module) do
    module.module_info[:attributes]
    |> Keyword.get(:behaviour, [])
    |> Enum.member?(Squest.MessageHandlerBehaviour)
  end
end
