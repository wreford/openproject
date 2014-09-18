require 'fog/aws/storage'
require 'carrierwave'

if OpenProject::Configuration.attachment_storage == :fog
  CarrierWave.configure do |config|
    config.fog_credentials = OpenProject::Configuration.fog_credentials
    config.fog_directory  = OpenProject::Configuration.fog_directory
    config.fog_public     = false
  end
end
