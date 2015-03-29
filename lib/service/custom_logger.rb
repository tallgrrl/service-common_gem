#custom_logger.rb
require 'logger'

module Service
  class CustomLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{msg}\n"
    end

  end
end