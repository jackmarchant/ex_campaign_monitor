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

  ```elixir
  ExCampaignMonitor.add_subscriber(%{email: "someone@domain.com", consent_to_track: "Yes"})
  > {:ok, %Subscriber{email: "someone@domain", consent_to_track: "Yes"}}
  ```
  """
  defdelegate add_subscriber(subscriber), to: Subscribers

  @doc """
  Update an existing subscriber from your list

  ```elixir
  ExCampaignMonitor.update_subscriber(%{
    old_email: "someone@domain.com",
    new_email: "person@domain.com",
    consent_to_track: "Yes"
  })
  > {:ok, %Subscriber{email: "person@domain.com", consent_to_track: "Yes"}}
  ```
  """
  defdelegate update_subscriber(subscriber), to: Subscribers

  @doc """
  Import many subscribers to your list

  ```elixir
  ExCampaignMonitor.import_subscribers([
    %{
      email: "someone@domain.com",
      consent_to_track: "Yes"
    },
    %{
      email: "person@domain.com",
      consent_to_track: "No"
    }
  ])
  > {:ok, 2}
  ```
  """
  defdelegate import_subscribers(subscribers), to: Subscribers

  @doc """
  Get a single subscriber by their email address

  ```elixir
  ExCampaignMonitor.get_subscriber_by_email("person@domain.com")
  > {:ok, %Subscriber{email: "person@domain.com", consent_to_track: "Yes"}}
  ```
  """
  defdelegate get_subscriber_by_email(email),
    to: Subscribers,
    as: :get_subscriber

  @doc """
  Unsubscribe someone who is currently subscribed to your list

  ```elixir
  ExCampaignMonitor.unsubscribe("person@domain.com")
  > {:ok, :unsubscribed}
  ```
  """
  defdelegate unsubscribe(subscriber), to: Subscribers

  @doc """
  Remove (delete) a single subscriber from your list

  ```elixir
  ExCampaignMonitor.remove_subscriber("person@domain.com")
  > {:ok, :removed}
  ```
  """
  defdelegate remove_subscriber(subscriber), to: Subscribers
end
