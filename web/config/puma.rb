workers ENV.fetch('WEB_CONCURRENCY') { 5 }
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count

preload_app!

port        ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  if defined?(Resque)
    Resque.redis = ENV['REDIS_URL'] # || 'redis://127.0.0.1:6379'
  end
end

plugin :tmp_restart
