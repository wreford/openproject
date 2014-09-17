require 'fog/aws/storage'
require 'carrierwave'

CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => 'AKIAJCLHKNUYJ2CXX3CA',
      :aws_secret_access_key  => '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',
      :region                 => 'eu-west-1'
  }
  config.fog_directory  = 'op-com-staging'
  config.fog_public     = false
end