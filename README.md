# ExCampaignMonitor

A simple wrapper for the Campaign Monitor JSON API.

## Installation

This package can be installed by adding `ex_campaign_monitor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_campaign_monitor, "~> 0.1"}
  ]
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
