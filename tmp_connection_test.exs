defmodule EnvLoader do
  @paths [".env", ".env.example"]

  def load! do
    case Enum.find(@paths, &File.exists?/1) do
      nil ->
        IO.puts("No .env or .env.example file found; using current environment variables")

      path ->
        path
        |> File.read!()
        |> parse()
        |> Enum.each(fn
          {_key, ""} -> :ok
          {key, value} -> System.put_env(key, value)
        end)

        IO.puts("Loaded environment variables from #{path}")
    end
  end

  defp parse(content) do
    content
    |> String.split(["\n", "\r\n"], trim: true)
    |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
    |> Enum.map(&String.split(&1, "=", parts: 2))
    |> Enum.filter(&match?([_, _], &1))
    |> Enum.map(fn [key, value] -> {key, normalize_value(value)} end)
  end

  defp normalize_value(value) do
    value = String.trim(value)

    if String.starts_with?(value, "\"") and String.ends_with?(value, "\"") do
      String.slice(value, 1..-2//-1)
    else
      value
    end
  end

  def default_db_config do
    %{
      username: System.get_env("DB_USERNAME") || "postgres.ekzplmvvoocodigjbxyd",
      password: System.get_env("DB_PASSWORD") || "Eco-habitUnilink",
      host: System.get_env("DB_HOST") || "aws-1-us-west-2.pooler.supabase.com",
      port: System.get_env("DB_PORT") || "5432",
      database: System.get_env("DB_NAME") || System.get_env("DB_DATABASE") || "postgres"
    }
  end

  def build_database_url_from_parts do
    config = default_db_config()

    if config.username && config.password && config.host && config.database do
      username = URI.encode_www_form(config.username)
      password = URI.encode_www_form(config.password)
      "postgresql://#{username}:#{password}@#{config.host}:#{config.port}/#{config.database}"
    end
  end
end

EnvLoader.load!()

# Read the Supabase connection string from the loaded env values.
db_url = System.get_env("SUPABASE_DATABASE_URL") || System.get_env("DATABASE_URL") || EnvLoader.build_database_url_from_parts()

unless db_url do
  raise "SUPABASE_DATABASE_URL, DATABASE_URL or DB_* database variables must be set for the database connection"
end

if Process.whereis(Ecohabits.Repo) do
  IO.puts("Existing Ecohabits.Repo process detected; stopping :ecohabits application to reconfigure Repo")
  :ok = Application.stop(:ecohabits)
end

repo_opts = [
  url: db_url,
  ssl: [verify: :verify_none],
  prepare: :unnamed,
  pool_size: 10,
  queue_target: 50,
  queue_interval: 1000,
  timeout: 15_000
]

host = URI.parse(db_url).host || "unknown"
IO.puts("Starting Ecohabits.Repo, DB host: #{host}")

{:ok, _} = Application.ensure_all_started(:logger)
{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _} = Application.ensure_all_started(:ecto_sql)

case Ecohabits.Repo.start_link(repo_opts) do
  {:ok, pid} ->
    IO.puts("Ecohabits.Repo started successfully")
    pid

  {:error, {:already_started, pid}} ->
    IO.puts("Ecohabits.Repo already started; using existing repo process")
    pid

  {:error, reason} ->
    raise "Ecohabits.Repo failed to start: #{inspect(reason)}"
end

IO.inspect(Ecohabits.Repo.query!("SELECT 1"), label: "DB connection")
