defmodule SQSMock do

  def start_link do
    Agent.start_link(
      fn ->
        %{
          existing_queues: %{}
        }
      end,
      name: __MODULE__
    )
  end

  def add_messages(queue_name, messages) do
    Agent.update(
      __MODULE__,
      fn state ->
        update_in(state, [:existing_queues, queue_name, :in_queue], &(&1 ++ messages))
      end
    )
  end

  def register_queue(queue_name) do
    Agent.update(
      __MODULE__,
      fn state ->
        put_in(state, [:existing_queues, queue_name], %{in_queue: [], in_flight: []})
      end
    )
    :ok
  end

  def receive_messages(queue_name, number) do
    Agent.get_and_update(
      __MODULE__,
      fn state ->
        in_queue = get_in(state, [:existing_queues, queue_name, :in_queue])
        {to_return, rest} = Enum.split(in_queue, number)

        new_state = update_in(state, [:existing_queues, queue_name], fn queue_state ->
          %{in_queue: rest, in_flight: queue_state.in_flight ++ to_return}
        end)

        {to_return, new_state}
      end
    )
  end

  def delete_message(queue_name, receipt_handle) do
    Agent.update(
      __MODULE__,

      fn state ->
        update_in(state, [:existing_queues, queue_name, :in_flight], fn messages ->
          Enum.reject(messages, &(&1.receipt_handle == receipt_handle))
        end)
      end
    )
  end

  def queue_exists?(queue_name) do
    Agent.get(
      __MODULE__,
      fn state -> get_in(state, [:existing_queues, queue_name]) != nil end
    )
  end

  def current_state do
    Agent.get(
      __MODULE__,
      fn state -> state end
    )
  end

  def change_message_visibility(_queue_name, _receipt_handle, _visibility_timeout) do
  end
end
