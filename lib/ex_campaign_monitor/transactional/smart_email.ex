defmodule ExCampaignMonitor.Transactional.SmartEmail do
  @moduledoc """
  Representation of a Smart Email
  """

  defstruct [:data, :to, :cc, :bcc, :add_recipients_to_list, :consent_to_track, :status, :message_id]
  
  @doc "Create a new SmartEmail struct"
  def new(params) do
    struct(__MODULE__, params)
  end
  
  @doc "Converts a map to a format CM understands"
  def to_cm(params) do
    smart_email = new(params)
    %{
      "Data" => smart_email.data,
      "To" => smart_email.to,
      "CC" => smart_email.cc,
      "BCC" => smart_email.bcc,
      "AddRecipientsToList" => smart_email.add_recipients_to_list,
      "ConsentToTrack" => smart_email.consent_to_track,
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
