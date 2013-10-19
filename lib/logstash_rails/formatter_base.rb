require 'logstash-event'
require 'socket'

module LogstashRails

  class FormatterBase

    def initialize(options = {})
      @flatten_params = (options[:flatten_params] != false)
    end

    def format(event_type, start, finish, id, payload)
      payload.merge!(
        process_id: $$,
        host:       Socket.gethostname,
        message:    event_type,
        source:     application_name
      )

      # process_action.action_controller events
      # from Rails4 contain Rack::Request instances
      # that are not serializable
      payload.delete(:request)

      flatten_params(payload)

      event = LogStash::Event.new(payload)

      event.timestamp = start

      event.to_json
    end

    private

    def application_name
      if defined?(Rails)
        Rails.application.class.parent_name
      end
    end

  end
end