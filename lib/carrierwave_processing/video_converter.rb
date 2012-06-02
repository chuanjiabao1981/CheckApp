module CarrierWave
  module VideoConverter
    extend ActiveSupport::Concern
    module ClassMethods
      def encode_video(target_format)
        process :encode_video => [target_format]
      end
    end

    def encode_video(format='mp4')
      # move upload to local cache
      cache_stored_file! if !cached?

      directory = File.dirname( current_path )

      # move upload to tmp file - encoding result will be saved to
      # original file name
      tmp_path   = File.join( directory, "tmpfile" )

      File.rename current_path, tmp_path

      Rails.logger.debug("----------------------------")
      Rails.logger.debug(tmp_path)
      Rails.logger.debug(File.size(tmp_path).to_s)

      # encode
      Voyeur::Video.new( filename: tmp_path ).convert( to: format.to_sym, output_filename: current_path )

      # because encoding video will change file extension, change it 
      # to old one
      fixed_name = File.basename(current_path, '.*') + "." + format.to_s
      File.rename File.join( directory, fixed_name ), current_path

      # delete tmp file
      File.delete tmp_path
    end

    private
      def prepare!
        cache_stored_file! if !cached?
      end
  end
end