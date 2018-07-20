defmodule ExCampaignMonitorTest.TransportTest do
  use ExUnit.Case

  import Mox

  describe "Transport" do
    test "request/2" do
      http_provider()
      |> expect(:post, fn url, body, _headers ->
        assert url == "https://api.createsend.com/api/v3.2/some_path"
        assert %{"hello" => "world"} == Jason.decode!(body)

        {:ok, http_response()}
      end)

      assert ExCampaignMonitor.Transport.request("/some_path", %{"hello" => "world"}) ==
               {:ok, %{"email" => "hi"}}
    end
  end

  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider)

  defp http_response do
    %HTTPoison.Response{
      status_code: 200,
      request_url: "https://api.createsend.com/api/v3.2/some_path",
      body: Jason.encode!(%{email: "hi"}),
      headers: ["Content-Type": "application/json"]
    }
  end
end
