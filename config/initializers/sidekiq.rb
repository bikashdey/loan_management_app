require 'sidekiq-scheduler'
require 'sidekiq'
require 'sidekiq-cron'


Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || Rails.application.secrets.redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || Rails.application.secrets.redis_url }
end


schedule_file = "config/sidekiq_schedule.yml"
if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(schedule_file))
end
