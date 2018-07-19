use Mix.Config

config :ex_campaign_monitor, :http_provider, HTTPoison

if Mix.env() == :test, do: import_config("#{Mix.env()}.exs")
