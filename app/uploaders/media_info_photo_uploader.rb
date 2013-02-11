# encoding: utf-8
# encoding: utf-8
require "carrierwave_quality"

class MediaInfoPhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
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
  # 如下两个目录方法修改一定要小心
  # 在测试完成后，删除这两个目录下所有文件，这个是写死在 spec_helpler文件中的
  def store_dir
    if Rails.env == "production"
      "report_media/media_info_photo/"
    else 
      "report_media/#{Rails.env}/media_info_photo/"
    end
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads/#{Rails.env}/media_info_photo/"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  #####process :resize_to_fill => [1000, 1000] 
  process :date_watermark
  process :quality => 90
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  #version :thumb do
  #  process :resize_to_fill => [50, 50]
  #end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  #def extension_white_list
  #  %w(jpg jpeg gif png)
  #end

  def date_watermark
    manipulate! do |img|
      if Rails.env != 'production'
        img
      else 
        text = Magick::Draw.new
        text.gravity = Magick::SouthWestGravity
        text.fill = 'red'
        text.pointsize = 32
        text.font_weight = Magick::BoldWeight
        text.annotate(img, 0, 0, 0, 0, Time.now.strftime("%Y/%m/%d %H:%M:%S"))
        img
      end
   end
  end


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
        @name ||= "#{secure_token}.jpg"
      end
    end
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
