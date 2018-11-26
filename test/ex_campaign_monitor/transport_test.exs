defmodule ExCampaignMonitorTest.TransportTest do
  use ExUnit.Case

  import Mox

  alias ExCampaignMonitor.Transport

  describe "Transport" do
    test "request/1" do
      http_provider()
      |> expect(:get, fn url, _headers ->
        assert url == "https://api.createsend.com/api/v3.2/some_get_path"
        {:ok, http_response(200, %{"EmailAddress" => "person@email.com"})}
      end)

      assert Transport.request("/some_get_path", :get) ==
               {:ok, %{"EmailAddress" => "person@email.com"}}
    end

    test "request/2" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == "https://api.createsend.com/api/v3.2/some_path"
        assert %{"hello" => "world"} == Jason.decode!(body)

        {:ok, http_response()}
      end)

      assert Transport.request("/some_path", :post, %{"hello" => "world"}) ==
               {:ok, %{"email" => "hi"}}
    end

    test "request/2 error" do
      http_provider()
      |> expect(:post, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      assert Transport.request("/some_path", :post, %{"hello" => "world"}) ==
               {:error, "Something went wrong."}
    end

    test "error in a successful response" do
      http_provider()
      |> expect(:post, fn _, _, _ ->
        {:ok, http_response(400, %{"Message" => "Failed to deserialize your request."})}
      end)

      assert Transport.request("/some_path", :post, %{"hi" => "there"}) == {:error, "Failed to deserialize your request."}
    end

    test "basic authentication" do
      http_provider()
      |> expect(:get, fn _url, headers ->
        assert headers == [
                 Authorization: "Basic dGVzdF9hcGlfa2V5Ong=",
                 "Content-Type": "application/json",
                 Accept: "application/json"
               ]

        {:ok, http_response()}
      end)

      Transport.request("/testing-auth", :get)
    end
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response(status_code \\ 200, body \\ %{email: "hi"}) do
    %HTTPoison.Response{
      status_code: status_code,
      request_url: "https://api.createsend.com/api/v3.2/some_path",
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
