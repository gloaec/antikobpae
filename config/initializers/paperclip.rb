module Paperclip
  class MediaTypeSpoofDetector
    private

    def type_from_file_command
      # -- original code removed --
      # begin
      #   Paperclip.run("file", "-b --mime-type :file", :file => @file.path)
      # rescue Cocaine::CommandLineError
      #   ""
      # end

      # -- new code follows --
      begin
         Paperclip.run("file", "-b --mime :file", :file => @file.path)
      rescue Cocaine::CommandLineError
        ""
      end
    end
  end

  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

Paperclip.options[:content_type_mappings] = { file: 'text/html' }
