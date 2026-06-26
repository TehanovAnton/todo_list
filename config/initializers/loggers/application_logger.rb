# frozen_string_literal: true

# ApplicationLogger — пишет логи работы приложения
#
# Вызывается вручную из bot.listen — в long polling нет HTTP-сервера,
# поэтому нотификации Action Controller не публикуются.

module ApplicationLogger
  class << self
    def logger
      @logger ||= begin
        log_path = Rails.root.join("log/application.log")
        logger = ActiveSupport::Logger.new(log_path, 10, 100.megabytes)
        logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
        logger
      end
    end

    def log(**args)
      entry = {
        timestamp:   Time.current.utc.iso8601(3),
        level:       "info",
        environment: Rails.env,
        type:        "application",
      }.merge!(**args)

      logger.info(entry.to_json)
    end
  end
end
