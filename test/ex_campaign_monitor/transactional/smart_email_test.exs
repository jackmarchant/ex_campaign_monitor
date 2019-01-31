defmodule ExCampaignMonitor.Transactional.SmartEmailTest do
  use ExUnit.Case

  alias ExCampaignMonitor.Transactional.SmartEmail

  describe "SmartEmail" do
    test "can convert to CM params" do
      assert SmartEmail.to_cm(%{
        data: %{username: "jack"}, 
        to: ["Jack Marchant <jack@jackmarchant.com>"],
        bcc: ["Joe Blogs <joe@blogs.com>"],
        cc: ["Richard Hendrix <richard@piedpiper.net>"],
        add_recipients_to_list: true,
        consent_to_track: "Yes"
      }) == %{
        "Data" => %{username: "jack"}, 
        "To" => ["Jack Marchant <jack@jackmarchant.com>"],
        "BCC" => ["Joe Blogs <joe@blogs.com>"],
        "CC" => ["Richard Hendrix <richard@piedpiper.net>"],
        "AddRecipientsToList" => true,
        "ConsentToTrack" => "Yes"
      }
    end

    test "can convert from CM response" do
      assert SmartEmail.from_cm(%{
        "Status" => "Accepted",
        "MessageID" => "a1a1a1a1",
        "Recipient" => "jack@jackmarchant.com" 
      }) == %SmartEmail{
        data: nil,
        status: "Accepted",
        message_id: "a1a1a1a1",
        to: "jack@jackmarchant.com",
        consent_to_track: nil
      }
    end
  end
end
