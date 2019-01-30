defmodule ExCampaignMonitor.Transactional do
  @moduledoc """
  Manage Transactional Emails
  Reference: https://www.campaignmonitor.com/api/transactional
  """

  alias ExCampaignMonitor.Transport
  alias ExCampaignMonitor.Transactional.SmartEmail

  @doc "Send a new Smart Email"
  def send_smart_email(smart_email_id, data) do
    "/transactional/smartEmail/#{smart_email_id}/send"
    |> Transport.request(:post, SmartEmail.to_cm(data))
    |> case do
      {:ok, response} -> {:ok, Enum.map(response, &SmartEmail.from_cm/1)}
      {:error, _} = error -> error
    end
  end
end
