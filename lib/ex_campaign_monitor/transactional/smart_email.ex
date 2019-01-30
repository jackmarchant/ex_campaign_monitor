defmodule ExCampaignMonitor.Transactional.SmartEmail do
  @moduledoc """
  Representation of a Smart Email
  """

  defstruct [:data, :to, :consent_to_track, :status, :message_id]
  
  @doc "Create a new SmartEmail struct"
  def new(params) do
    struct(__MODULE__, params)
  end
  
  @doc "Converts a map to a format CM understands"
  def to_cm(%{data: data, to: to, consent_to_track: consent}) do
    %{
      "Data" => data,
      "To" => to,
      "ConsentToTrack" => consent
    }
  end
  
  @doc "Convert the response from CM to a SmartEmail struct"
  def from_cm(%{
    "Status" => status,
    "Recipient" => to,
    "MessageID" => message_id
  }) do
    new(%{
      status: status,
      to: to,
      message_id: message_id
    })
  end
end
