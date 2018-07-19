use Mix.Config

config :ex_campaign_monitor, :http_provider, HTTPoison

import_config("#{Mix.env()}.exs")
