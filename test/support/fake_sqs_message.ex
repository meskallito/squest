defmodule FakeSQSMessage do
  defstruct [:receipt_handle, :__queue_name__]

  def new(attributes \\ %{}) do
    struct(__MODULE__, Map.merge(default_attributes(), attributes))
  end

  defp default_attributes do
    %{
      __queue_name__: "test_queue_name",
      receipt_handle: UUID.uuid1()
    }
  end
end
