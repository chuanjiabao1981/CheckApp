# encoding: utf-8
# encoding: utf-8
require "carrierwave_processing/video_converter"
class MediaInfoVideoUploader < CarrierWave::Uploader::Base

  include CarrierWave::VideoConverter


  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  before :store, :remember_cache_id
  after :store, :delete_tmp_dir
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env == "production"
       "report_media/media_info_video/"
    else
      "report_media/#{Rails.env}/media_info_video/"
    end
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads/#{Rails.env}/media_info_video/"
  end

  #version :mp4 do
  #  process :encode_video => [:mp4]
  #  def full_filename(for_file)
  #    "#{File.basename(for_file, File.extname(for_file))}.mp4"
  #  end
  #end

  #version :webm do
  #  process :encode_video => [:webm]
  #  def full_filename(for_file)
  #    "#{File.basename(for_file, File.extname(for_file))}.webm"
  #  end
  #end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #def extension_white_list
  #   %w(3gp mp4 m4v)
  #end
   # store! nil's the cache_id after it finishes so we need to remember it for deletion
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end
  
  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
      FileUtils.rm_rf(File.join(cache_dir, @cache_id_was))
    end
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def filename
    if original_filename.present?
      if not file.extension.empty?
        @name ||= "#{secure_token}.#{file.extension}" 
      else
        @name ||= "#{secure_token}.mp4"
      end
    end
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end