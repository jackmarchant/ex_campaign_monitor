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

  defp base_api_path, do: "/lists/#{campaign_monitor_client_id()}"

  defp campaign_monitor_client_id, do: Application.get_env(:ex_campaign_monitor, :client_id)
end
