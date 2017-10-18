# Squest

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `squest` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:squest, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/squest](https://hexdocs.pm/squest).

## Usage

Currently library suppors one pipeline per queue.
Squest is launching its own supervisor that can be used to manually create processing pipeline for
given queue:

```elixir
Squest.register_queue("queue_name", YourJobHandler, workers_count: 2)
```

Alternatively you can launch your own supervisor with:

```elixir
  children = [
    {Squest.QueuePoller, ["test", YourJobHandler, [workers_count: 10]]},
  ]

  opts = [strategy: :one_for_one, name: YourApp.Supervisor]
  Supervisor.start_link(children, opts)
```

Your handler should be defined as follows:

```elixir
defmodule YourApp.TestHandler do
  use Squest.MessageHandler
  require Logger

  def handle_message(sqs_message) do
    Logger.debug("Processing in the handler #{inspect(sqs_message)}")
  end
end
```

By default Squest uses exponential back-off. It means if your job raises an error it will be
rescheduled based on the number of previous retries as a power of 2 in seconds.







