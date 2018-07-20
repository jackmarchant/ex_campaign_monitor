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
  def add_subscriber(%{email: email, consent_to_track: ctt}) do
    get_api_path()
    |> Transport.request(%{"EmailAddress" => email, "ConsentToTrack" => ctt})
    |> case do
      {:ok, %{"email" => email}} ->
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
    "email=#{old_email}"
    |> get_api_path()
    |> Transport.request(%{"EmailAddress" => new_email, "ConsentToTrack" => ctt})
    |> case do
      {:ok, _} -> {:ok, %Subscriber{email: new_email, consent_to_track: ctt}}
      {:error, _} = error -> error
    end
  end

  defp get_api_path, do: "/subscribers/#{campaign_monitor_list_id()}.json"
  defp get_api_path(params), do: get_api_path() <> "?" <> params

  defp campaign_monitor_list_id, do: Application.get_env(:ex_campaign_monitor, :list_id)
end
