defmodule Steer.Lightning do
  use GenServer
  require Logger

  alias Steer.Repo
  alias Steer.Lightning.Models


  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    { :ok, state }
  end

  def sync() do
    Steer.Sync.Channel.sync
    Steer.Sync.Forward.sync

    Logger.info "Sync done at #{DateTime.utc_now()}"
  end

  def get_all_channels() do
    GenServer.call(__MODULE__, :get_all_channels)
  end

  def get_channel(%{ id: _id } = params) do
    GenServer.call(__MODULE__, { :get_channel, params })
  end

  def get_channel_forwards(%{ channel_id: _ } = params) do
    GenServer.call(__MODULE__, { :get_channel_forwards, params })
  end

  def get_latest_unconsolidated_forward do
    GenServer.call(__MODULE__, :get_latest_unconsolidated_forward)
  end

  def handle_call(:get_all_channels, _from, %{ channels: channels } = state) do
    Logger.info "Getting channels from cache"

    { :reply, channels, state}
  end

  def handle_call(:get_all_channels, _from, state) do
    channels = Repo.get_all_channels()
    |> Models.Channel.format_balances

    { :reply,
      channels,
      state |> Map.put(:channels, channels)}
  end

  def handle_call({ :get_channel, %{ id: id } }, _from, state) do
    Logger.info "Getting channel #{id} from cache"

    channel = Repo.get_channel(id)
    |> Models.Channel.format_balances

    { :reply, channel, state}
  end

  def handle_call({ :get_channel_forwards, %{ channel_id: channel_id } }, _from, state) do
    channel = Repo.get_channel(channel_id)

    forwards = channel_id
    |> Repo.get_channel_forwards()
    |> Models.Forward.format_balances
    |> Models.Forward.contextualize_forwards(channel)

    { :reply, forwards, state}
  end

  def handle_call(:get_latest_unconsolidated_forward, _from, state) do
    { :reply, Repo.get_latest_unconsolidated_forward, state}
  end
end
