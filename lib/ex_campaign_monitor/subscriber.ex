defmodule ExCampaignMonitor.Subscriber do
  defstruct [:email, :name, :custom_fields, :consent_to_track, :state]

  @doc """
  Create a new subscriber struct
  """
  def new(params) do
    struct(__MODULE__, params)
  end

  @doc """
  Create a struct from Campaign Monitor's API response
  """
  def from_cm(%{
        "EmailAddress" => email,
        "ConsentToTrack" => ctt,
        "Name" => name,
        "CustomFields" => custom_fields,
        "State" => state
      }) do
    new(%{
      email: email,
      consent_to_track: ctt,
      name: name,
      custom_fields: convert_keys(custom_fields, &key_to_atom/1),
      state: state
    })
  end

  def to_cm(subscriber) do
    params = Map.take(subscriber, [:email, :name, :custom_fields, :consent_to_track])

    %{
      "EmailAddress" => params[:email],
      "ConsentToTrack" => params[:consent_to_track],
      "Name" => params[:name],
      "CustomFields" => convert_keys(params[:custom_fields], &key_to_string/1)
    }
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  defp key_to_atom(str) do
    str
    |> String.downcase()
    |> String.to_atom()
  end

  defp key_to_string(atom) do
    atom
    |> Atom.to_string()
    |> String.capitalize()
  end

  defp convert_keys(nil, _), do: nil

  defp convert_keys(list, converter) when is_list(list) do
    Enum.map(list, &convert_keys(&1, converter))
  end

  defp convert_keys(map, converter) do
    for {key, val} <- map, into: %{}, do: {converter.(key), val}
  end
end
