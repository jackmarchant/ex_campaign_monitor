defmodule ExCampaignMonitorTest do
  use ExUnit.Case

  alias ExCampaignMonitor.Subscriber
  alias ExCampaignMonitor.List, as: ExCMList

  import Mox

  @subscriber_email "jack@jackmarchant.com"
  @subscribers_url "https://api.createsend.com/api/v3.2/subscribers/test_list_id"
  @lists_url "https://api.createsend.com/api/v3.2/lists/test_client_id"
  @list_by_id_url "https://api.createsend.com/api/v3.2/lists/"
  @transactional_url "https://api.createsend.com/api/v3.2/transactional"

  describe "ExCampaignMonitor Subscribers" do
    setup :verify_on_exit!

    test "add_subscriber/1 success with minimum fields" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @subscribers_url <> ".json"
        decoded_body = Jason.decode!(body)

        assert %{
                 "ConsentToTrack" => "Yes",
                 "EmailAddress" => decoded_body["EmailAddress"]
               } == decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{
               email: @subscriber_email,
               consent_to_track: "Yes"
             }) == {:ok, %Subscriber{email: @subscriber_email, consent_to_track: "Yes"}}
    end

    test "add_subscriber/1 success with all fields" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @subscribers_url <> ".json"
        decoded_body = Jason.decode!(body)

        assert %{
                 "ConsentToTrack" => "Yes",
                 "EmailAddress" => decoded_body["EmailAddress"],
                 "CustomFields" => [
                   %{
                     "Key" => "website",
                     "Value" => "https://www.jackmarchant.com"
                   }
                 ],
                 "Name" => "Jack"
               } == decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{
               email: @subscriber_email,
               consent_to_track: "Yes",
               name: "Jack",
               state: "active",
               custom_fields: [
                 %{
                   key: "website",
                   value: "https://www.jackmarchant.com"
                 }
               ]
             }) == {:ok, %Subscriber{email: @subscriber_email, consent_to_track: "Yes"}}
    end

    test "add_subscriber/1 error" do
      http_provider()
      |> expect(:post, fn url, _body, _headers ->
        assert url == @subscribers_url <> ".json"

        {:error, http_error()}
      end)

      assert ExCampaignMonitor.add_subscriber(%{email: "", consent_to_track: ""}) ==
               {:error, "Something went wrong."}
    end

    test "update_subscriber/1" do
      http_provider()
      |> expect(:put, fn url, body, _headers ->
        assert url == @subscribers_url <> ".json?email=#{@subscriber_email}"
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
      |> expect(:put, fn _url, _body, _headers ->
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
        assert url == @subscribers_url <> "/import.json"
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

    test "get_subscriber_by_email/1 success" do
      email = "bob@hello.com"

      http_provider()
      |> expect(:get, fn url, _headers ->
        assert url == @subscribers_url <> ".json?email=#{email}&includetrackingpreference=true"

        {:ok,
         http_response(%{
           "EmailAddress" => email,
           "ConsentToTrack" => "Yes",
           "Name" => "Jack Marchant",
           "CustomFields" => [],
           "State" => "active"
         })}
      end)

      assert ExCampaignMonitor.get_subscriber_by_email(email) ==
               {:ok,
                %Subscriber{
                  email: email,
                  consent_to_track: "Yes",
                  name: "Jack Marchant",
                  custom_fields: [],
                  state: "active"
                }}
    end

    test "get_subscriber_by_email/1 error" do
      http_provider()
      |> expect(:get, fn _url, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.get_subscriber_by_email("person@email.com") ==
               {:error, "Something went wrong."}
    end

    test "unsubscribe/1 success" do
      email = "bob@hello.com"

      http_provider()
      |> expect(:post, fn url, body, _headers ->
        decoded = Jason.decode!(body)
        assert decoded["EmailAddress"] == email
        assert url == @subscribers_url <> "/unsubscribe.json"
        {:ok, http_response(%{})}
      end)

      assert ExCampaignMonitor.unsubscribe(email) == {:ok, :unsubscribed}
    end

    test "unsubscribe/1 error" do
      http_provider()
      |> expect(:post, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.unsubscribe("person@email.com") ==
               {:error, "Something went wrong."}
    end

    test "remove_subscriber/1" do
      email = "bob@hello.com"

      http_provider()
      |> expect(:delete, fn url, _headers ->
        assert url == @subscribers_url <> ".json?email=#{email}"
        {:ok, http_response(%{})}
      end)

      assert ExCampaignMonitor.remove_subscriber(email) == {:ok, :removed}
    end

    test "remove_subscriber/1 error" do
      http_provider()
      |> expect(:delete, fn _url, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.remove_subscriber("person@email.com") ==
               {:error, "Something went wrong."}
    end
  end

  describe "ExCampaignMonitor Lists" do
    setup :verify_on_exit!

    test "create_list/1 success with minimum fields" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @lists_url <> ".json"
        decoded_body = Jason.decode!(body)

        assert %{"Title" => "this is my list title"} == decoded_body

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.create_list(%{
               title: "this is my list title"
             }) == {:ok, %ExCMList{title: "this is my list title"}}
    end

    test "create_list/1 error" do
      http_provider()
      |> expect(:post, fn url, _body, _headers ->
        assert url == @lists_url <> ".json"

        {:error, http_error()}
      end)

      assert ExCampaignMonitor.create_list(%{title: nil}) == {:error, "Something went wrong."}
    end

    test "get_active_subscribers/1 success" do
      list_id = "a1a1a1a1"

      http_provider()
      |> expect(:get, fn url, _headers ->
        assert url == @list_by_id_url <> list_id <> ".json"

        {:ok,
         http_response(%{
           "Title" => "my cool list",
           "ListID" => list_id,
           "ConfirmedOptIn" => true,
           "UnsubscribePage" => "http://www.example.com/unsubscribed.html",
           "UnsubscribeSetting" => "AllClientLists",
           "ConfirmationSuccessPage" => "http://www.example.com/joined.html"
         })}
      end)

      assert ExCampaignMonitor.get_list_by_id(list_id) ==
               {:ok,
                %ExCMList{
                  title: "my cool list",
                  list_id: list_id,
                  confirmed_opt_in: true,
                  unsubscribe_page: "http://www.example.com/unsubscribed.html",
                  unsubscribe_setting: "AllClientLists",
                  confirmation_success_page: "http://www.example.com/joined.html"
                }}
    end

    test "get_list_by_id/1 error" do
      http_provider()
      |> expect(:get, fn _url, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.get_list_by_id("list-id-does-not-exist") ==
               {:error, "Something went wrong."}
    end

    test "get_list_by_id/1 success" do
      list_id = "a1a1a1a1"

      http_provider()
      |> expect(:get, fn url, _headers ->
        assert url == @list_by_id_url <> list_id <> ".json"

        {:ok,
         http_response(%{
           "Results" => [
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
         })}
      end)

      assert ExCampaignMonitor.get_active_subscribers(list_id) ==
               {:ok,
                %ExCMList{
                  active_subscribers: [
                    %ExCampaignMonitor.Subscriber{
                      consent_to_track: "No",
                      custom_fields: [%{key: "website", value: "https://www.jackmarchant.com"}],
                      email: "jack@jackmarchant.com",
                      name: "Jack Marchant",
                      state: "active"
                    }
                  ]
                }}
    end

    test "get_active_subscribers/1 error" do
      http_provider()
      |> expect(:get, fn _url, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.get_active_subscribers("list-id-does-not-exist") ==
               {:error, "Something went wrong."}
    end

    test "create_webhook/3 success" do
      list_id = "a1a1a1a1"

      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == @list_by_id_url <> list_id <> "/webhooks" <> ".json"
        decoded_body = Jason.decode!(body)
        assert decoded_body["Events"] == ["Subscribe"]
        assert decoded_body["Url"] == "http://example.com/subscribe"
        assert decoded_body["PayloadFormat"] == "json"

        {:ok, http_response("982u981u298u298u2e9u289e")}
      end)

      assert ExCampaignMonitor.create_webhook(
               list_id,
               ["Subscribe"],
               "http://example.com/subscribe"
             ) == {:ok, "982u981u298u298u2e9u289e"}
    end

    test "create_webhook/4 error" do
      http_provider()
      |> expect(:post, fn _url, body, _headers ->
        decoded_body = Jason.decode!(body)
        assert decoded_body["PayloadFormat"] == "unsupported-format"
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.create_webhook(
               "list-id-does-not-exist",
               [],
               "no-url",
               "unsupported-format"
             ) == {:error, "Something went wrong."}
    end
    
    
    test "activate_webhook/2 success" do
      list_id = "a1a1a1a1"
      webhook_id = "982u981u298u298u2e9u289e"

      http_provider()
      |> expect(:put, fn url, body, _headers ->
        assert url == "#{@list_by_id_url <> list_id}/webhooks/#{webhook_id}/activate.json"
        decoded_body = Jason.decode!(body)
        assert decoded_body == ""
        {:ok, http_response(webhook_id)}
      end)

      ExCampaignMonitor.activate_webhook(list_id, webhook_id)
    end
  

    test "activate_webhook/2 error" do
      http_provider()
      |> expect(:put, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      ExCampaignMonitor.activate_webhook("invalid-list-id", "invalid-webhook-id")
    end

    test "list_webhooks/1 success" do
      list_id = "a1a1a1a1"

      http_provider()
      |> expect(:get, fn url, _headers ->
        assert url == @list_by_id_url <> list_id <> "/webhooks.json"
        {:ok, 
          http_response([
            %{
              "WebhookID" => "ee1b3864e5ca61618q98su98qsu9q",
              "Events" => ["Subscribe"],
              "Url" => "http://example.com/subscribe",
              "Status" => "Active",
              "PayloadFormat" => "Json"
            }
          ])
        }
      end)

      {:ok, result} = ExCampaignMonitor.list_webhooks(list_id)
      assert result == [
        %ExCampaignMonitor.Webhook{
          id: "ee1b3864e5ca61618q98su98qsu9q",
          events: ["Subscribe"],
          url: "http://example.com/subscribe",
          status: "Active",
          payload_format: "Json"
        }
      ]
    end

    test "list_webhooks/1 error" do
      http_provider()
      |> expect(:get, fn _url, _headers -> 
        {:error, http_error()}
      end)

      assert {:error, "Something went wrong."} == ExCampaignMonitor.list_webhooks("invalid-list-id")
    end

    test "delete_webhook/2 success" do
      list_id = "a1a1a1a1"
      webhook_id = "982u981u298u298u2e9u289e"

      http_provider()
      |> expect(:delete, fn url, _headers ->
        assert url == @list_by_id_url <> list_id <> "/webhooks/" <> webhook_id <> ".json"

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.delete_webhook(list_id, webhook_id) == {:ok, :webhook_deleted}
    end

    test "delete_webhook/2 error" do
      http_provider()
      |> expect(:delete, fn _url, _headers ->
        {:error, http_error()}
      end)

      assert ExCampaignMonitor.delete_webhook("list-id-does-not-exist", "webhook-id-invalid") ==
               {:error, "Something went wrong."}
    end
  end
 
  test "send_smart_email/2 success" do
    smart_email_id = "a1a1a1a1"
    data = %{
      data: %{username: "jack"},
      to: ["Jack Marchant <jack@jackmarchant.com>"],
      bcc: ["Joe Blogs <joe@blogs.com>"],
      add_recipients_to_list: true,
      consent_to_track: "yes"
    }

    http_provider()
    |> expect(:post, fn url, body, _headers ->
      assert url == @transactional_url <> "/smartEmail/#{smart_email_id}/send"
      assert body == Jason.encode!(%{
        "Data" => data.data,
        "To" => data.to,
        "CC" => nil,
        "BCC" => data.bcc,
        "AddRecipientsToList" => true,
        "ConsentToTrack" => "yes"
      })
      
      {:ok, 
        http_response([%{
          "MessageID" => "ee1b3864e5ca61618q98su98qsu9q",
          "Status" => "Accepted",
          "Recipient" => "jack@jackmarchant.com"
        }])
      }
    end)

    {:ok, result} = ExCampaignMonitor.send_smart_email(smart_email_id, data)
    assert result == [%ExCampaignMonitor.Transactional.SmartEmail{
      data: nil,
      message_id: "ee1b3864e5ca61618q98su98qsu9q",
      status: "Accepted",
      to: "jack@jackmarchant.com",
      consent_to_track: nil
    }]
  end


  test "send_smart_email/2 error" do
    http_provider()
    |> expect(:post, fn _url, _body, _headers ->
      {:error, http_error()}
    end)

    assert ExCampaignMonitor.send_smart_email("a1a1a1a1", %{data: %{}, to: nil, consent_to_track: nil}) 
    == {:error, "Something went wrong."}
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response, do: http_response(%{email: @subscriber_email})

  defp http_response(body) do
    %HTTPoison.Response{
      status_code: 200,
      request_url: @subscribers_url,
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
