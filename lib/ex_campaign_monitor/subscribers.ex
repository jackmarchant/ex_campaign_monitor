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
    |> Transport.request(:post, Subscriber.to_cm(subscriber))
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
    |> Transport.request(:put, Subscriber.to_cm(%{email: new_email, consent_to_track: ctt}))
    |> case do
      {:ok, _} -> {:ok, %Subscriber{email: new_email, consent_to_track: ctt}}
      {:error, _} = error -> error
    end
  end

  @spec import_subscribers(list(map())) :: {:ok, integer()} | {:error, String.t()}
  @doc """
  Import subscribers
  """
  def import_subscribers(subscribers) when is_list(subscribers) do
    "#{base_api_path()}/import.json"
    |> Transport.request(:post, %{"Subscribers" => Enum.map(subscribers, &Subscriber.to_cm/1)})
    |> case do
      {:ok, %{"TotalNewSubscribers" => total}} -> {:ok, total}
      {:error, _} = error -> error
    end
  end

  @spec get_subscriber(String.t(), boolean()) :: {:ok, Subscriber.t()} | {:error, String.t()}
  @doc """
  Get details of a specific subscriber
  """
  def get_subscriber(email, with_tracking_preference \\ true) do
    "#{base_api_path()}.json?email=#{email}&includetrackingpreference=#{with_tracking_preference}"
    |> Transport.request(:get)
    |> case do
      {:ok, response} -> {:ok, Subscriber.from_cm(response)}
      {:error, _} = error -> error
    end
  end

  @spec unsubscribe(String.t()) :: {:ok, :unsubscribed} | {:error, String.t()}
  @doc """
  Unsubscribe a subscriber
  """
  def unsubscribe(email) do
    "#{base_api_path()}/unsubscribe.json"
    |> Transport.request(:post, %{"EmailAddress" => email})
    |> case do
      {:ok, _} -> {:ok, :unsubscribed}
      {:error, _} = error -> error
    end
  end

  @spec remove_subscriber(String.t()) :: {:ok, :removed} | {:error, String.t()}
  def remove_subscriber(email) do
    "#{base_api_path()}.json?email=#{email}"
    |> Transport.request(:delete)
    |> case do
      {:ok, _} -> {:ok, :removed}
      {:error, _} = error -> error
    end
  end

  defp base_api_path, do: "/subscribers/#{campaign_monitor_list_id()}"

  defp campaign_monitor_list_id, do: Application.get_env(:ex_campaign_monitor, :list_id)
end
