defmodule ExCampaignMonitorTest.TransportTest do
  use ExUnit.Case

  import Mox

  alias ExCampaignMonitor.Transport

  describe "Transport" do
    test "request/1" do
      http_provider()
      |> expect(:get, fn url ->
        assert url == "https://api.createsend.com/api/v3.2/some_get_path"
        {:ok, http_response(%{"EmailAddress" => "person@email.com"})}
      end)

      assert Transport.request("/some_get_path") == {:ok, %{"EmailAddress" => "person@email.com"}}
    end

    test "request/2" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == "https://api.createsend.com/api/v3.2/some_path"
        assert %{"hello" => "world"} == Jason.decode!(body)

        {:ok, http_response()}
      end)

      assert Transport.request("/some_path", %{"hello" => "world"}) == {:ok, %{"email" => "hi"}}
    end

    test "request/2 error" do
      http_provider()
      |> expect(:post, fn _url, _body, _headers ->
        {:error, http_error()}
      end)

      assert Transport.request("/some_path", %{"hello" => "world"}) ==
               {:error, "Something went wrong."}
    end
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response(body \\ %{email: "hi"}) do
    %HTTPoison.Response{
      status_code: 200,
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
