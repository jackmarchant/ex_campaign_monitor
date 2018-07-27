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

  @doc """
  Create an API request format for Campaign Monitor
  """
  def to_cm(%__MODULE__{
        email: email,
        consent_to_track: ctt,
        name: name,
        custom_fields: custom_fields,
        state: state
      }) do
    %{
      "EmailAddress" => email,
      "ConsentToTrack" => ctt,
      "Name" => name,
      "CustomFields" => convert_keys(custom_fields, &key_to_string/1),
      "State" => state
    }
  end

  defp key_to_atom(str), do: str |> String.downcase() |> String.to_atom()
  defp key_to_string(str), do: str |> Atom.to_string() |> String.capitalize()

  defp convert_keys(list, converter) when is_list(list) do
    Enum.map(list, &convert_keys(&1, converter))
  end

  defp convert_keys(map, converter) do
    for {key, val} <- map, into: %{}, do: {converter.(key), val}
  end
end
