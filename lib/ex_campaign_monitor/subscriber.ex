defmodule ExCampaignMonitor.Subscriber do
  defstruct [:email, :consent_to_track]

  def new(params) do
    struct(__MODULE__, params)
  end
end
