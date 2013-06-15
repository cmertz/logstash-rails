module LogstashRails

  # base class for all transports
  #
  class ConfigurationBase

    # @param options [Hash]
    #
    # @option options [Array]  :events The list of events to subscribe
    # @option options [Logger] :logger The logger for exceptions
    #
    def initialize(options)
      @events = options[:events] || [/.*/]
      @logger = options[:logger]

      if defined?(Rails)
        @logger ||= Rails.logger
      end

      subscribe
    end

    # destroy
    #
    # unsubscribe from ActiveSupport::Notifications
    #
    def destroy
      return unless @subscriptions

      @subscriptions.each do |subscription|
        ActiveSupport::Notifications.unsubscribe(subscription)
      end
    end

    private

    def subscribe
      @subscriptions = @events.map do |event|
        ActiveSupport::Notifications.subscribe(event, method(:event_handler))
      end
    end

    def event_handler(*args)
      json_event = Formatter.format(*args)

      begin
        push(json_event)
      rescue
        log($!)
      end
    end

    def log(exception)
      msg = exception.message + "\n " + exception.backtrace.join("\n ")
      @logger.error(msg) if @logger
    end

  end
end
