defmodule ExCampaignMonitor.Lists do
  @moduledoc """
  Covers all your list management needs

  Provide your Campaign Monitor Client ID to use this module:
  ```
  config :ex_campaign_monitor, :client_id, "YOUR_CLIENT_ID"
  ```
  """

  alias ExCampaignMonitor.{Transport, List}

  @doc """
  Create a new list

  Must provide a :title`, and optionally:
    * :unsubscribe_page
    * :unsubscribe_setting
    * :confirmed_opt_in
    * :confirmation_success_page
  """
  def create_list(params) do
    list =
      Map.take(params, [
        :title,
        :unsubscribe_page,
        :unsubscribe_setting,
        :confirmed_opt_in,
        :confirmation_success_page
      ])

    "#{base_api_path()}.json"
    |> Transport.request(:post, List.to_cm(list))
    |> case do
      {:ok, _} ->
        {:ok, %List{title: list[:title]}}

      {:error, _} = error ->
        error
    end
  end

  @spec get_list_by_id(String.t()) :: {:ok, List.t()} | {:error, String.t()}
  @doc """
  Get details of a specific list by ListID
  """
  def get_list_by_id(list_id) do
    "/lists/#{list_id}.json"
    |> Transport.request(:get)
    |> case do
      {:ok, response} -> {:ok, List.from_cm(response)}
      {:error, _} = error -> error
    end
  end

  @spec get_active_subscribers(String.t()) :: {:ok, List.t()} | {:error, String.t()}
  @doc """
  Get a list with active subscribers
  """
  def get_active_subscribers(list_id) do
    "/lists/#{list_id}.json"
    |> Transport.request(:get)
    |> case do
      {:ok, response} -> {:ok, List.from_cm(response)}
      {:error, _} = error -> error
    end
  end

  @spec create_webhook(String.t(), list(String.t()), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  @doc """
  Create a webhook for a list
  """
  def create_webhook(list_id, events, url, payload_format \\ "json") when is_list(events) do
    "/lists/#{list_id}/webhooks.json"
    |> Transport.request(:post, %{
      "Events" => events,
      "Url" => url,
      "PayloadFormat" => payload_format
    })
    |> case do
      {:ok, webhook_id} -> {:ok, webhook_id}
      {:error, _} = error -> error
    end
  end

  @spec activate_webhook(String.t(), String.t()) :: :ok | {:error, String.t()}
  @doc """
  Activate a webhook for a List
  """
  def activate_webhook(list_id, webhook_id) do
    "/lists/#{list_id}/webhooks/#{webhook_id}/activate"
    |> Transport.request(:put, "")
    |> case do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end

  @spec delete_webhook(String.t(), String.t()) :: {:ok, Atom.t()} | {:error, String.t()}
  @doc """
  Delete a webhook for a list
  """
  def delete_webhook(list_id, webhook_id) do
    "/lists/#{list_id}/webhooks/#{webhook_id}.json"
    |> Transport.request(:delete)
    |> case do
      {:ok, _} -> {:ok, :webhook_deleted}
      {:error, _} = error -> error
    end
  end

  defp base_api_path, do: "/lists/#{campaign_monitor_client_id()}"

  defp campaign_monitor_client_id, do: Application.get_env(:ex_campaign_monitor, :client_id)
end
