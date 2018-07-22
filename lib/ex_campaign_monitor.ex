defmodule ExCampaignMonitor do
  @moduledoc """
  A wrapper for the Campaign Monitor JSON API

  1. Install the package by adding `ex_campaign_monitor` to your list of dependencies in `mix.exs`:
  ```elixir
  def deps do
    [
      {:ex_campaign_monitor, "~> 0.2"}
    ]
  end
  ```

  2. Add your Campaign Monitor account API key and a List ID to your application's config:
  ```elixir
    config :ex_campaign_monitor,
      :api_key, "YOUR_API_KEY",
      :list_id, "YOUR_LIST_ID",
  ```

  3. Call a function on the `ExCampaignMonitor` module, for example:
  ```elixir
  defmodule MyApp.PageController do
    use MyAppWeb, :controller

    def index(conn, params) do
      ExCampaignMonitor.add_subscriber(%{
        email: params["email"], # email address of the user you want to subscribe
        consent_to_track: "Yes" # https://help.campaignmonitor.com/consent-to-track
      })
      send_resp(conn, "Subscriber added")
    end
  end
  """
  alias ExCampaignMonitor.Subscribers

  @doc """
  Add a new subscriber to your list
  """
  defdelegate add_subscriber(subscriber), to: Subscribers

  @doc """
  Update an existing subscriber from your list
  """
  defdelegate update_subscriber(subscriber), to: Subscribers

  @doc """
  Import many subscribers to your list
  """
  defdelegate import_subscribers(subscribers), to: Subscribers

  @doc """
  Get a single subscriber by their email address
  """
  defdelegate get_subscriber_by_email(email),
    to: Subscribers,
    as: :get_subscriber

  # @doc """
  # Remove (delete) a single subscriber from your list
  # """
  # defdelegate remove_subscriber(subscriber), to: Subscribers

  # TODO:
  # defdelegate unsubscribe(subscriber), to: Subscribers
end
