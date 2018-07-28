defmodule ExCampaignMonitor.List do
  @moduledoc """
  A List in Campaign Monitor represents a group of subscribers
  """

  alias ExCampaignMonitor.Subscriber

  defstruct [
    :title,
    :confirmed_opt_in,
    :unsubscribe_page,
    :unsubscribe_setting,
    :list_id,
    :confirmation_success_page,
    :active_subscribers
  ]

  @doc """
  Create a new list struct
  """
  def new(params) do
    struct(__MODULE__, params)
  end

  @doc """
  Create a struct from Campaign Monitor's API response
  """
  def from_cm(%{
        "ConfirmedOptIn" => confirmed_opt_in,
        "Title" => title,
        "UnsubscribePage" => unsubscribe_page,
        "UnsubscribeSetting" => unsubscribe_setting,
        "ListID" => list_id,
        "ConfirmationSuccessPage" => confirmation_success_page
      }) do
    new(%{
      title: title,
      confirmed_opt_in: confirmed_opt_in,
      unsubscribe_page: unsubscribe_page,
      unsubscribe_setting: unsubscribe_setting,
      list_id: list_id,
      confirmation_success_page: confirmation_success_page
    })
  end

  def from_cm(%{
        "Results" => subscribers
      }) do
    new(%{
      active_subscribers: Enum.map(subscribers, &Subscriber.from_cm/1)
    })
  end

  @doc """
  Convert a map to a Campaign Monitor List
  """
  def to_cm(list) do
    params =
      Map.take(list, [
        :title,
        :confirmed_opt_in,
        :unsubscribe_page,
        :unsubscribe_setting,
        :list_id,
        :confirmation_success_page
      ])

    %{
      "Title" => params[:title],
      "ConfirmedOptIn" => params[:confirmed_opt_in],
      "UnsubscribePage" => params[:unsubscribe_page],
      "UnsubscribeSetting" => params[:unsubscribe_setting],
      "ListID" => params[:list_id],
      "ConfirmationSuccessPage" => params[:confirmation_success_page]
    }
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
