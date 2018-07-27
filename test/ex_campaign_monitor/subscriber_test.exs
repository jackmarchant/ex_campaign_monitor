defmodule ExCampaignMonitorTest.SubscriberTest do
  use ExUnit.Case

  alias ExCampaignMonitor.Subscriber

  describe "Subscriber" do
    setup do
      custom_fields = [
        %{
          key: "website",
          value: "https://www.jackmarchant.com"
        },
        %{
          key: "interests",
          value: "Elixir"
        }
      ]

      %{custom_fields: custom_fields}
    end

    test "it can be created", %{custom_fields: custom_fields} do
      assert Subscriber.new(%{
               name: "Jack Marchant",
               email: "jack@jackmarchant.com",
               consent_to_track: "No",
               custom_fields: custom_fields,
               state: "active"
             }) == %Subscriber{
               name: "Jack Marchant",
               custom_fields: custom_fields,
               email: "jack@jackmarchant.com",
               consent_to_track: "No",
               state: "active"
             }
    end

    test "it can be created from campaign monitor API", %{custom_fields: custom_fields} do
      assert Subscriber.from_cm(%{
               "EmailAddress" => "jack@jackmarchant.com",
               "ConsentToTrack" => "No",
               "Name" => "Jack Marchant",
               "CustomFields" => [
                 %{
                   "Key" => "website",
                   "Value" => "https://www.jackmarchant.com"
                 },
                 %{
                   "Key" => "interests",
                   "Value" => "Elixir"
                 }
               ],
               "State" => "active"
             }) == %Subscriber{
               email: "jack@jackmarchant.com",
               consent_to_track: "No",
               name: "Jack Marchant",
               custom_fields: custom_fields,
               state: "active"
             }
    end

    test "it can be created to match API request format", %{custom_fields: custom_fields} do
      assert Subscriber.to_cm(%Subscriber{
               email: "jack@jackmarchant.com",
               consent_to_track: "No",
               name: "Jack Marchant",
               custom_fields: custom_fields
             }) == %{
               "EmailAddress" => "jack@jackmarchant.com",
               "ConsentToTrack" => "No",
               "Name" => "Jack Marchant",
               "CustomFields" => [
                 %{
                   "Key" => "website",
                   "Value" => "https://www.jackmarchant.com"
                 },
                 %{
                   "Key" => "interests",
                   "Value" => "Elixir"
                 }
               ]
             }
    end
  end
end
