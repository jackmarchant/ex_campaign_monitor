defmodule ExCampaignMonitor.Transactional.SmartEmailTest do
  use ExUnit.Case

  alias ExCampaignMonitor.Transactional.SmartEmail

  describe "SmartEmail" do
    test "can convert to CM params" do
      assert SmartEmail.to_cm(%{
        data: %{username: "jack"}, 
        to: "jack@jackmarchant.com"
      }) == %{
        "Data" => %{username: "jack"}, 
        "To" => "jack@jackmarchant.com"
      }
    end

    test "can conver from CM response" do
      assert SmartEmail.from_cm(%{
        "Status" => "Accepted",
        "MessageID" => "a1a1a1a1",
        "Recipient" => "jack@jackmarchant.com" 
      }) == %SmartEmail{
        data: nil,
        status: "Accepted",
        message_id: "a1a1a1a1",
        to: "jack@jackmarchant.com"
      }
    end
  end
end
