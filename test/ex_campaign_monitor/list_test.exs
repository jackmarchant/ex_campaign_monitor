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
  end
end
