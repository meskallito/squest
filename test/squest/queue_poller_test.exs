defmodule Squest.QueuePollerTest do
  use ExUnit.Case, async: true

  alias Squest.QueuePoller, as: P

  import ExUnit.CaptureLog

  require Logger

  defmodule WrongHandler do
  end

  defmodule EmptyTestHandler do
    use Squest.MessageHandler
    def handle_message(_message), do: :ok
  end

  setup do
    SQSMock.register_queue("test_queue_name")
    sqs_message = FakeSQSMessage.new()
    SQSMock.add_messages("test_queue_name", [sqs_message])
    [sqs_message: sqs_message]
  end

  test "message handler doesn't implement MessageHandlerBehaviour" do
    assert_raise Squest.QueuePoller.BadMessageHandlerError, fn ->
      assert P.init(["test_queue_name", WrongHandler, []]) == {}
    end
  end

  test "queue doesn't exist" do
    assert_raise Squest.QueuePoller.NonExistentQueueError, fn ->
      assert P.init(["non_existing_queue_name", EmptyTestHandler, []]) == {}
    end
  end

  test "sucessful message processing", %{sqs_message: sqs_message} do
    P.start_link(["test_queue_name", MessageHandlerMock, [idle_timeout: 10]])
    :timer.sleep(20)

    assert MessageHandlerMock.handled_messages() == [sqs_message]
  end

  test "sets correct max_demand for ConsumerSupervisor workers" do
    assert capture_log(fn ->
      P.start_link(["test_queue_name", MessageHandlerMock, [idle_timeout: 10, workers_count: 10]])
    end) =~ "producer configuration: [max_demand: 10, min_demand: 1]"
  end

  test "pass buggy message to retry strategy", %{sqs_message: sqs_message} do
    assert capture_log(fn ->
      P.start_link([
        "test_queue_name",
        BuggyMessageHandlerMock,
        [idle_timeout: 10, retry_strategy: RetryStrategyMock]
      ])
      :timer.sleep(20)
    end) =~ "retry strategy: RetryStrategyMock"

    assert RetryStrategyMock.incoming_messages() == [sqs_message]
  end
end
