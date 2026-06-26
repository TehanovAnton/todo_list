# frozen_string_literal: true

# Error Logger — пишет JSON-лог необработанных исключений в log/errors.log.
#
# Вызывается из двух мест:
#   1. ApplicationInteraction — перехватывает ошибки внутри интеракторов
#   2. bot.listen в rake-таске — перехватывает всё что не поймал интерактор

module ErrorLogger
  class << self
    def logger
      @logger ||= begin
        log_path = Rails.root.join("log/errors.log")
        logger = ActiveSupport::Logger.new(log_path, 10, 100.megabytes)
        logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
        logger
      end
    end

    def log(exception, context: {})
      entry = {
        timestamp:   Time.current.utc.iso8601(3),
        level:       "error",
        environment: Rails.env,
        type:        "error",
        error_class: exception.class.name,
        message:     exception.message,
        backtrace:   exception.backtrace&.first(10),
        context:     context
      }

      logger.error(entry.to_json)
    end
  end
end
