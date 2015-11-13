Exbands
=======

Exbands is the LastFM music bands fetcher written in Elixir. It fetch most popular bands by english and russian letters and stores them in local PostgreSQL database. You should have artists table with fields: name, created_at, updated_at in your databse to use it.

The speed of processing depends on LastFM API responses time. Usually it takes from 40s to 2 minutes.

![example](https://cloud.githubusercontent.com/assets/854386/11154016/be0f69e6-8a4d-11e5-96f7-32006c36bbf5.png)


## Installation

Clone this repo
```
git clone git@github.com:mendab1e/exbands.git
```

## Usage

First you need to [create your LastFM application](http://www.last.fm/api/account/create)

Set your API key and configurations for your PostgreSQL database in ```config/config.exs```

```
config :exbands, api_key: "your_key"
config :exbands, database: "db_name"
config :exbands, username: "postgres"
config :exbands, password: "postgres"
```
Compile the application
```
MIX_ENV=prod mix escript.build
```
Run it
```
./exbands
```

## Contributing

1. Fork it ( https://github.com/mendab1e/exbands/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request