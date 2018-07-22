defmodule ExCampaignMonitor.Subscriber do
  defstruct [:email, :consent_to_track]

  @doc """
  Create a new subscriber struct
  """
  def new(params) do
    struct(__MODULE__, params)
  end

  @doc """
  Create a struct from Campaign Monitor's API response
  """
  def from_cm(%{"EmailAddress" => email, "ConsentToTrack" => ctt}) do
    new(%{email: email, consent_to_track: ctt})
  end
end
