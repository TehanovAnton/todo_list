# frozen_string_literal: true

# Telegram Logger — пишет JSON-лог каждого входящего Telegram-апдейта в log/http.log.
#
# Вызывается вручную из bot.listen — в long polling нет HTTP-сервера,
# поэтому нотификации Action Controller не публикуются.

module TelegramLogger
  class << self
    def logger
      @logger ||= begin
        log_path = Rails.root.join("log/telegram.log")
        logger = ActiveSupport::Logger.new(log_path, 10, 100.megabytes)
        logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
        logger
      end
    end

    def log(message)
      entry = {
        timestamp:   Time.current.utc.iso8601(3),
        level:       "info",
        environment: Rails.env,
        type:        "telegram_update",
        message_id:  message.message_id,
        chat_id:     message.chat&.id,
        username:    message.from&.username,
        text:        message.text
      }

      logger.info(entry.to_json)
    end
  end
end
