# ExCampaignMonitor

[![CircleCI](https://circleci.com/gh/jackmarchant/ex_campaign_monitor.svg?style=svg)](https://circleci.com/gh/jackmarchant/ex_campaign_monitor)
[![codecov](https://codecov.io/gh/jackmarchant/ex_campaign_monitor/branch/master/graph/badge.svg)](https://codecov.io/gh/jackmarchant/ex_campaign_monitor)
[![Hex.pm version](https://img.shields.io/hexpm/v/ex_campaign_monitor.svg)](https://hex.pm/packages/ex_campaign_monitor)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/ex_campaign_monitor.svg)](https://hex.pm/packages/ex_campaign_monitor)

A simple wrapper for the Campaign Monitor JSON API.

## Installation

1. Install the package by adding `ex_campaign_monitor` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:ex_campaign_monitor, "~> 0.1"}
  ]
end
```

2. Add your Campaign Monitor account API key and a List ID to your application's config:
```elixir
  config :ex_campaign_monitor,
    :api_key, "YOUR_API_KEY",
    :list_id, "YOUR_LIST_ID",
```

3. Call a function on the `ExCampaignMonitor` module, for example:
```elixir
defmodule MyApp.PageController do
  use MyAppWeb, :controller

  def index(conn, params) do
    ExCampaignMonitor.add_subscriber(%{
      email: params["email"], # email address of the user you want to subscribe
      consent_to_track: "Yes" | "No" # https://help.campaignmonitor.com/consent-to-track
    })
    send_resp(conn, "Subscriber added")
  end
end
```

## Features
- [Subscribers](https://www.campaignmonitor.com/api/subscribers/)
  - [x] Adding a subscriber
  - [ ] Updating a subscriber
  - [ ] Importing many subscribers
  - [ ] Getting a subscriber's details
  - [ ] Unsubscribing a subscriber
  - [ ] Deleting a subscriber
- [Lists](https://www.campaignmonitor.com/api/lists/)
  - [ ] Active subscribers
  - [ ] Creating a List
  - [ ] Creating a webhook
  - [ ] Deactivating a webhook
