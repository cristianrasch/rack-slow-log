module Rack
  class SlowLog
    class Logger

      def initialize(long_request_time, slow_log, one_log_per_request)
        @long_request_time = long_request_time
        @slow_log = slow_log
        @one_log_per_request = one_log_per_request

        @lines = []
      end

      def log(line)
        @lines << [Time.now, line]
      end
      alias_method :<<, :log

      def save
        if long_request?
          write_log
        end
      end

      def request_start!
        @start_time = Time.now
      end

      def request_end!
        @end_time = Time.now
      end

      private

      def time_elapsed
        @time_elapsed ||= @end_time - @start_time
      end

      def long_request?
        (@end_time - @start_time) > @long_request_time
      end

      def write_log
        log_file = ::File.open(log_file_name, 'a')

        @lines.each do |timestamp, line|
          log_file.write("[#{timestamp}] #{line} (#{time_elapsed.round(1)} ms)\n")
        end
        # log_file.write("[#{@start_time}] >>>>>>>>>> START <<<<<<<<<<\n")
        # @lines.each { |timestamp, line| log_file.write("[#{timestamp}] #{line}\n") }
        # log_file.write("[#{@end_time}] >>>>>>>>>> END <<<<<<<<<<\n")

        log_file.close
      end

      def log_file_name
        if @one_log_per_request
          time_stamp = @start_time.strftime('%Y-%m-%d-%H_%M_%S.%3N')
          "#{@slow_log}_#{time_stamp}"
        else
          @slow_log
        end
      end

    end
  end
end
