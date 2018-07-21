defmodule ExCampaignMonitor.Subscribers do
  @moduledoc """
  Provide your Campaign Monitor List ID to use this module:
  ```
  config :ex_campaign_monitor, :list_id, "YOUR_LIST_ID"
  ```
  """

  alias ExCampaignMonitor.{Transport, Subscriber}

  @spec add_subscriber(map()) :: {:ok, Subscriber.t()} | {:error, String.t()}
  @doc """
  Add a single subscriber to a list
  """
  def add_subscriber(%{email: email, consent_to_track: ctt} = subscriber) do
    "#{base_api_path()}.json"
    |> Transport.request(to_cm_subscriber(subscriber))
    |> case do
      {:ok, _} ->
        {:ok, %Subscriber{email: email, consent_to_track: ctt}}

      {:error, _} = error ->
        error
    end
  end

  @spec update_subscriber(map()) :: {:ok, Subscriber.t()} | {:error, String.t()}
  @doc """
  Update a subscriber
  """
  def update_subscriber(%{old_email: old_email, new_email: new_email, consent_to_track: ctt}) do
    "#{base_api_path()}.json?email=#{old_email}"
    |> Transport.request(to_cm_subscriber(%{email: new_email, consent_to_track: ctt}))
    |> case do
      {:ok, _} -> {:ok, %Subscriber{email: new_email, consent_to_track: ctt}}
      {:error, _} = error -> error
    end
  end

  @spec import_subscribers(list(map())) :: {:ok, integer()} | {:error, String.t()}
  @doc """
  Import subscribers
  """
  def import_subscribers(subscribers) do
    "#{base_api_path()}/import.json"
    |> Transport.request(%{"Subscribers" => Enum.map(subscribers, &to_cm_subscriber/1)})
    |> case do
      {:ok, %{"TotalNewSubscribers" => total}} -> {:ok, total}
      {:error, _} = error -> error
    end
  end

  defp to_cm_subscriber(%{email: email, consent_to_track: ctt}) do
    %{
      "EmailAddress" => email,
      "ConsentToTrack" => ctt
    }
  end

  defp to_cm_subscriber(_), do: nil

  defp base_api_path, do: "/subscribers/#{campaign_monitor_list_id()}"

  defp campaign_monitor_list_id, do: Application.get_env(:ex_campaign_monitor, :list_id)
end
