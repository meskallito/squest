defmodule Squest.PipelineTest do
  use ExUnit.Case, async: true

  alias Squest.Pipeline, as: P
  require Logger

  defmodule WrongHandler do
  end

  defmodule EmptyTestHandler do
    use Squest.MessageHandler
    def handle_message(_message), do: :ok
  end

  # TODO:
  #   test parallel processing?
  #   test error processing
  #
  setup_all do
    SQSMock.register_queue("test_queue_name")
    sqs_message = FakeSQSMessage.new()
    SQSMock.add_messages("test_queue_name", [sqs_message])
    [sqs_message: sqs_message]
  end

  test "message handler doesn't implement MessageHandlerBehaviour" do
    assert_raise Squest.Pipeline.BadMessageHandlerError, fn ->
      assert P.init(["test_queue_name", WrongHandler, []]) == {}
    end
  end

  test "queue doesn't exist" do
    assert_raise Squest.Pipeline.NonExistentQueueError, fn ->
      assert P.init(["non_existing_queue_name", EmptyTestHandler, []]) == {}
    end
  end

  test "sucessful message processing", %{sqs_message: sqs_message} do
    P.start_link(["test_queue_name", MessageHandlerMock, [idle_timeout: 10]])
    :timer.sleep(20)
    assert MessageHandlerMock.handled_messages() == [sqs_message]
  end
end
