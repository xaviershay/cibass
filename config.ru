$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'cibass/instance'
require 'cibass/server'
require 'cibass/pusher'

def extract_from_env(key)
  ENV[key] || raise("#{key} not found in ENV")
end

instance = Cibass::Instance.new(
  working_directory: extract_from_env('CIBASS_WORKING_DIR'),
  config_repository: extract_from_env('CIBASS_CONFIG_REPO')
)

map '/ws' do
  run Cibass::Pusher.new(instance)
end

map '/' do
  run Cibass::Server.new(instance)
end
