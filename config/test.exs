use Mix.Config

config :ex_campaign_monitor, :list_id, "test_list_id"
config :ex_campaign_monitor, :api_key, "test_api_key"
config :ex_campaign_monitor, :client_id, "test_client_id"

config :ex_campaign_monitor, :http_provider, ExCampaignMonitor.HTTPoisonMock
