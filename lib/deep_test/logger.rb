module DeepTest
  class Logger < ::Logger
    def initialize(*args)
      super
      hostname = Socket.gethostname
      self.formatter = proc { |severity, time, progname, msg| "[DeepTest@#{hostname}] #{time.strftime "%F %T"} #{msg}\n" }
      self.level = configured_log_level
    end

    def io_stream
      @logdev.dev
    end

    def configured_log_level
      if ENV['DEEP_TEST_LOG_LEVEL']
        Logger.const_get(ENV['DEEP_TEST_LOG_LEVEL'].upcase)
      else
        Logger::INFO
      end
    end

    def add severity, message, progname=nil, &block
      super severity, message, &block
    rescue Exception => e
      super severity,"#{e.class}: #{e} occurred logging on #{e.backtrace.first}", &nil
    end
  end
end
