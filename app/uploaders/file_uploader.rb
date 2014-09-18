require 'carrierwave/processing/encryption'

class FileUploader < CarrierWave::Uploader::Base
  def self.storage_type
    OpenProject::Configuration.attachment_storage
  end

  def self.use_encryption?
    OpenProject::Configuration.encrypt_attachments?
  end

  storage storage_type

  if use_encryption?
    include CarrierWave::Encryption

    process :encrypt # @TODO make encryption (secret etc.) configurable
  end

  def local?
    self.class.storage_type == :file
  end

  def remote?
    not local?
  end

  def encrypted?
    self.respond_to? :encrypt
  end

  def store_dir
    if local?
      file_store_dir
    else
      fog_store_dir
    end
  end

  def file_store_dir
    @store_dir ||= (OpenProject::Configuration['attachments_storage_path'] ||
                    Rails.root.join('files').to_s)
  end

  def fog_store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    'tmp/uploads'
  end
end
