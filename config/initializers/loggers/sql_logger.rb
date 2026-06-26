# frozen_string_literal: true

# SQL Logger — пишет структурированные JSON-логи в log/sql.log
#
# Каждый SQL-запрос ActiveRecord публикует событие `sql.active_record` через
# ActiveSupport::Notifications. Мы подписываемся на него и пишем JSON-строку
# в отдельный файл — это позволяет не засорять основной лог и легко скормить
# файл в Filebeat/Kibana.

module SqlLogger
  # Запросы с такими именами — внутренние служебные запросы Rails.
  # Логировать их смысла нет.
  IGNORED_NAMES = %w[
    SCHEMA
    ActiveRecord::SchemaMigration
    ActiveRecord::InternalMetadata
  ].freeze

  # Порог медленного запроса в миллисекундах.
  SLOW_QUERY_THRESHOLD_MS = 100

  FILE_PATH = {
    'default' => "log/sql.log"
  }

  class << self
    def logger
      @logger ||= begin
        log_path = Rails.root.join(FILE_PATH['default'])
        logger = ActiveSupport::Logger.new(log_path, 10, 100.megabytes)
        logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
        logger
      end
    end

    def log(event)
      payload = event.payload

      # Пропускаем служебные запросы и запросы без имени
      name = payload[:name].to_s
      return if IGNORED_NAMES.include?(name)
      return if name.blank?

      duration_ms = event.duration.round(2)

      entry = {
        timestamp:   Time.current.utc.iso8601(3),
        level:       duration_ms >= SLOW_QUERY_THRESHOLD_MS ? "warn" : "info",
        environment: Rails.env,
        type:        "sql",
        name:        name,
        sql:         payload[:sql],
        duration_ms: duration_ms,
        slow:        duration_ms >= SLOW_QUERY_THRESHOLD_MS,
        cached:      payload[:cached] || false,
        thread_id:   Thread.current.object_id
      }

      logger.info(entry.to_json)
    end
  end
end

ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  SqlLogger.log(event)
end
