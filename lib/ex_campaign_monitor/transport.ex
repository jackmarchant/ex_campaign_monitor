defmodule ExCampaignMonitor.Transport do
  @base_api "https://api.createsend.com/api/v3.2"
  @http_provider Application.get_env(:ex_campaign_monitor, :http_provider)

  @callback request(String.t(), map()) :: {:ok, HTTPoison.Response} | {:error, HTTPoison.Error}
  def request(path, body) do
    @http_provider.post(@base_api <> path, Jason.encode!(body), headers())
  end

  defp token do
    Base.encode64("#{campaign_monitor_api_key()}:x")
  end

  defp headers do
    [
      Authorization: "Basic #{token()}",
      "Content-Type": "application/json",
      Accept: "application/json"
    ]
  end

  defp campaign_monitor_api_key, do: Application.get_env(:ex_campaign_monitor, :api_key)
end
