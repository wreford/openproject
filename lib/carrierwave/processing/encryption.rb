# encoding: utf-8

require 'fileutils'

module CarrierWave
  ##
  # This processor encrypts files before storing them.
  # To use it require this file:
  #
  #     require 'carrierwave/processing/encryption'
  #
  # And then include it in your uploader:
  #
  #     class MyUploader < CarrierWave::Uploader::Base
  #       include CarrierWave::Encryption
  #     end
  #
  # You can now use the provided helpers:
  #
  #     class MyUploader < CarrierWave::Uploader::Base
  #       include CarrierWave::Encryption
  #
  #       process :encrypt
  #     end
  #
  # === Note
  #
  # You can find more information here:
  #
  # https://github.com/opf/carrierwave_encryption/
  #
  #
  module Encryption
    extend ActiveSupport::Concern

    module ClassMethods
      def encrypt
        process :encrypt
      end
    end

    def encrypt_file(input_file, output_file)
      cipher.encrypt_file input_file, output_file
    end

    def decrypt_file(input_file, output_file)
      cipher.decrypt_file input_file, output_file
    end

    def self.cipher
      # @TODO this has to be made configurable obviously ...
      Gibberish::AES.new('wurst234', 256)
    end

    def cipher
      Encryption.cipher
    end

    def encrypt
      fetch

      unless file_encrypted? current_path
        enc_file = append_ext current_path, 'enc'

        encrypt_file current_path, enc_file
        FileUtils.rm current_path
        FileUtils.mv enc_file, current_path
      end
    end

    ##
    # Decrypts the file and returns the path to the decrypted file.
    def decrypt
      fetch

      decrypted_path = append_ext current_path, 'dec'
      decrypt_file current_path, decrypted_path

      decrypted_path
    end

    def append_ext(path, ext)
      path.chomp(File.extname(path)) + ".#{ext}"
    end

    def fetch
      cache_stored_file! unless local? || cached?
    end

    def file_encrypted?(file)
      File.open(file, 'r') { |f| f.read(8) == 'Salted__' }
    end
  end # Encryption
end # CarrierWave
