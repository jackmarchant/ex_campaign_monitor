defmodule ExCampaignMonitor.Lists do
  alias ExCampaignMonitor.Transport

  @spec add_subscriber(map()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def add_subscriber(%{email: email, consent_to_track: ctt}) do
    path = "/subscribers/#{campaign_monitor_list_id()}.json"
    Transport.request(path, %{"EmailAddress" => email, "ConsentToTrack" => ctt})
  end

  defp campaign_monitor_list_id, do: Application.get_env(:ex_campaign_monitor, :list_id)
end
