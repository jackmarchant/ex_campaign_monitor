defmodule ExCampaignMonitorTest.ListTest do
  use ExUnit.Case

  alias ExCampaignMonitor.List, as: ExCMList

  describe "List" do
    test "it can be created" do
      assert ExCMList.new(%{
               title: "my title"
             }) == %ExCMList{
               title: "my title"
             }
    end

    test "it can be created from campaign monitor API with minimum params" do
      assert ExCMList.from_cm(%{
               "Title" => "my title",
               "ConfirmedOptIn" => false,
               "UnsubscribePage" => nil,
               "UnsubscribeSetting" => nil,
               "ListID" => "a1a1a1a1a1",
               "ConfirmationSuccessPage" => nil
             }) == %ExCMList{
               title: "my title",
               confirmed_opt_in: false,
               unsubscribe_page: nil,
               unsubscribe_setting: nil,
               list_id: "a1a1a1a1a1",
               confirmation_success_page: nil
             }
    end

    test "it can be created to match API request format" do
      assert ExCMList.to_cm(%ExCMList{
               title: "my list"
             }) == %{
               "Title" => "my list"
             }
    end

    test "it can be created for active subscribers list" do
      subscribers = [
        %{
          "EmailAddress" => "jack@jackmarchant.com",
          "ConsentToTrack" => "No",
          "Name" => "Jack Marchant",
          "CustomFields" => [
            %{
              "Key" => "website",
              "Value" => "https://www.jackmarchant.com"
            }
          ],
          "State" => "active"
        }
      ]

      assert ExCMList.from_cm(%{"Results" => subscribers}) == %ExCMList{
               active_subscribers: [
                 %ExCampaignMonitor.Subscriber{
                   consent_to_track: "No",
                   custom_fields: [%{key: "website", value: "https://www.jackmarchant.com"}],
                   email: "jack@jackmarchant.com",
                   name: "Jack Marchant",
                   state: "active"
                 }
               ]
             }
    end
  end
end
