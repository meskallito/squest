defmodule Squest.Pipeline.ConsumerSupervisor do
  use ConsumerSupervisor

  alias Squest.Pipeline.MessageConsumer

  require Logger

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      worker(MessageConsumer, [
        Keyword.get(args, :message_handler),
        Keyword.get(args, :retry_strategy)
      ], restart: :temporary)
    ]

    {:ok, children, strategy: :one_for_one, subscribe_to: Keyword.get(args, :producers)}
  end
end
