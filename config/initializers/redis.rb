redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  connect_timeout: 5,
  read_timeout: 5,
  write_timeout: 5
}

$redis = Redis.new(redis_config)
