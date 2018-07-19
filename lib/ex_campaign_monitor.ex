defmodule ExCampaignMonitor do
  @moduledoc """
  A wrapper for the Campaign Monitor JSON API
  """
  alias ExCampaignMonitor.Lists

  defdelegate add_subscriber(email), to: Lists
end
