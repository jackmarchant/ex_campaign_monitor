defmodule ExCampaignMonitor.Transport do
  @base_api "https://api.createsend.com/api/v3.2"

  @doc """
  Make a request to Campaign Monitor's API
  """
  @callback request(String.t(), Atom.t()) :: {:ok, map()} | {:error, String.t()}

  def request(path, type) when type in [:get, :delete] do
    http_provider()
    |> apply(type, [@base_api <> path, headers()])
    |> process_response()
  end

  @callback request(String.t(), Atom.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def request(path, type, body) when type in [:post, :put] do
    http_provider()
    |> apply(type, [@base_api <> path, Jason.encode!(body), headers()])
    |> process_response()
  end

  defp process_response({:ok, %HTTPoison.Response{body: "", status_code: status_code}})
  when status_code in 200..299, do: {:ok, ""}
  defp process_response({:ok, %HTTPoison.Response{body: body, status_code: status_code}})
  when status_code in 200..299, do: {:ok, Jason.decode!(body)}
  defp process_response({:ok, %HTTPoison.Response{body: body}}) do
    case Jason.decode(body) do
      {:ok, body} -> {:error, body["Message"]}
      {:error, _} -> {:error, body}
    end
  end
  defp process_response({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}

  defp token do
    Base.encode64("#{campaign_monitor_api_key()}:x")
  end

  defp headers do
    [
      Authorization: "Basic #{token()}",
      "Content-Type": "application/json",
      Accept: "application/json"
    ]
  end

  defp campaign_monitor_api_key, do: Application.get_env(:ex_campaign_monitor, :api_key)
  defp http_provider, do: Application.get_env(:ex_campaign_monitor, :http_provider, HTTPoison)
end
