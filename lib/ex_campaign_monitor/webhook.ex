defmodule ExCampaignMonitor.Webhook do
  @moduledoc """
  A Webhook represents a request that can be sent to a URL, when
  an event happens in Campaign Monitor, which you would like to
  be notified of. For example, when a Subscriber's information 
  is updated, Campaign Monitor can send your web server
  """

  defstruct [
    :id,
    :events,
    :url,
    :status,
    :payload_format
  ]

  @doc """
  Create a new webhook struct
  """
  def new(params) do
    struct(__MODULE__, params)
  end

  @doc """
  Create a struct from Campaign Monitor's API response
  """
  def from_cm(%{
    "WebhookID" => webhook_id,
    "Events" => events,
    "Url" => url,
    "Status" => status,
    "PayloadFormat" => payload_format
  }) do
    new(%{
      id: webhook_id,
      events: events,
      url: url,
      status: status,
      payload_format: payload_format
    })
  end
end
