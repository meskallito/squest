defmodule SQSMock do

  def start_link do
    Agent.start_link(
      fn -> [existing_queues: []] end,
      name: __MODULE__
    )
  end

  def register_queue(queue_name) do
    Agent.update(
      __MODULE__,
      fn state -> Keyword.update(state, :existing_queues, [], &(&1 ++ [queue_name])) end
    )
    :ok
  end

  def receive_messages(queue_name, number) do
  end

  def delete_message(queue_name, receipt_handle) do
  end

  def queue_exists?(queue_name) do
    Agent.get(
      __MODULE__,
      fn state -> Keyword.get(state, :existing_queues) |> Enum.member?(queue_name) end
    )
  end

  def current_state do
    Agent.get(
      __MODULE__,
      fn state -> state end
    )
  end

  def change_message_visibility(queue_name, receipt_handle, visibility_timeout) do
  end
end
