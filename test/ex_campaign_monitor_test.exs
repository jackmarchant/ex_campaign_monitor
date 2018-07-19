defmodule ExCampaignMonitorTest do
  use ExUnit.Case

  import Mox

  @subscriber_email "jack@jackmarchant.com"
  @list_url "https://api.createsend.com/api/v3.2/subscribers/test_list_id.json"

  describe "ExCampaignMonitor" do
    setup :verify_on_exit!

    test "add_subscriber/1" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @list_url
        decoded_body = Jason.decode!(body)

        assert %{"ConsentToTrack" => "Yes", "EmailAddress" => decoded_body["EmailAddress"]} ==
                 decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{
               email: @subscriber_email,
               consent_to_track: "Yes"
             }) == {:ok, http_response()}
    end
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response do
    %HTTPoison.Response{
      status_code: 200,
      request_url: @list_url,
      body: Jason.encode!(%{email: @subscriber_email}),
      headers: ["Content-Type": "application/json"]
    }
  end
end
