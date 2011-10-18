require RUBY_VERSION < '1.9' ? 'system_timer' : 'timeout'
SystemTimer ||= Timeout

module Rack
  class Timeout
    @timeout = 15
    class << self
      attr_accessor :timeout
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        SystemTimer.timeout(self.class.timeout, ::Timeout::Error) { @app.call(env) }
      rescue ::Timeout::Error => e
        # clean up the mongo connection and reraise
        puts "*** Timeout, cleaning up the mongo connection"
        Mongoid.try(:master).try(:connection).try(:reconnect)
        
        raise
      end
    end

  end
end
