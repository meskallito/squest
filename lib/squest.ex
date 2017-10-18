defmodule Squest do
  @moduledoc """
  Documentation for Squest.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Squest.hello
      :world

  """
  alias Squest.QueuePollerPool

  def register_queue(queue_path, message_handler, options \\ []) do
    QueuePollerPool.start_queue_poller(queue_path, message_handler, options)
  end
end
