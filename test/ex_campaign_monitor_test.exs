defmodule ExCampaignMonitorTest do
  use ExUnit.Case

  alias ExCampaignMonitor.Subscriber

  import Mox

  @subscriber_email "jack@jackmarchant.com"
  @list_url "https://api.createsend.com/api/v3.2/subscribers/test_list_id"

  describe "ExCampaignMonitor" do
    setup :verify_on_exit!

    test "add_subscriber/1 success" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @list_url <> ".json"
        decoded_body = Jason.decode!(body)

        assert %{"ConsentToTrack" => "Yes", "EmailAddress" => decoded_body["EmailAddress"]} ==
                 decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{
               email: @subscriber_email,
               consent_to_track: "Yes"
             }) == {:ok, %Subscriber{email: @subscriber_email, consent_to_track: "Yes"}}
    end

    test "add_subscriber/1 error" do
      http_provider()
      |> expect(:post, fn url, _body, _headers ->
        assert url == @list_url <> ".json"

        {:error, http_error()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{email: "", consent_to_track: ""}) ==
               {:error, "Something went wrong."}
    end

    test "update_subscriber/1" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @list_url <> ".json?email=#{@subscriber_email}"
        decoded_body = Jason.decode!(body)

        assert %{"ConsentToTrack" => "No", "EmailAddress" => decoded_body["EmailAddress"]} ==
                 decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.update_subscriber(%{
               old_email: @subscriber_email,
               new_email: "bob@email.com",
               consent_to_track: "No"
             }) == {:ok, %Subscriber{email: "bob@email.com", consent_to_track: "No"}}
    end

    test "update_subscriber/1 error" do
      http_provider()
      |> expect(:post, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.update_subscriber(%{
               old_email: "",
               new_email: "",
               consent_to_track: ""
             }) == {:error, "Something went wrong."}
    end

    test "import_subscribers/1" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @list_url <> "/import.json"
        decoded_body = Jason.decode!(body)

        email =
          decoded_body["Subscribers"]
          |> List.first()
          |> Map.get("EmailAddress")

        assert %{
                 "Subscribers" => [
                   %{"ConsentToTrack" => "No", "EmailAddress" => email}
                 ]
               } == decoded_body

        {:ok, http_response(%{TotalNewSubscribers: length(decoded_body["Subscribers"])})}
      end)

      assert ExCampaignMonitor.import_subscribers([
               %{
                 email: "bob@email.com",
                 consent_to_track: "No"
               }
             ]) == {:ok, 1}
    end

    test "import_subscribers/1 error" do
      http_provider()
      |> expect(:post, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.import_subscribers([
               %{
                 email: "",
                 consent_to_track: ""
               }
             ]) == {:error, "Something went wrong."}
    end

    test "get_subscriber_by_email/1" do
      email = "bob@hello.com"

      http_provider()
      |> expect(:get, fn url ->
        assert url == @list_url <> ".json?email=#{email}&includetrackingpreference=true"
        {:ok, http_response(%{"EmailAddress" => email, "ConsentToTrack" => "Yes"})}
      end)

      assert ExCampaignMonitor.get_subscriber_by_email(email) ==
               {:ok, %Subscriber{email: email, consent_to_track: "Yes"}}
    end
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response, do: http_response(%{email: @subscriber_email})

  defp http_response(body) do
    %HTTPoison.Response{
      status_code: 200,
      request_url: @list_url,
      body: Jason.encode!(body),
      headers: ["Content-Type": "application/json"]
    }
  end

  defp http_error do
    %HTTPoison.Error{
      reason: "Something went wrong."
    }
  end
end
