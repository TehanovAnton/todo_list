# frozen_string_literal: true

require 'telegram/bot'
require 'prometheus/client/push'

namespace :money_tracker do
  desc 'Starts moeny traker bot'
  task start: :environment do
    token = Settings.app.telegram.bot.moeny_tracker_bot.token

    Telegram::Bot::Client.run(token) do |bot|
      puts 'Start bot'

      bot.listen do |message|
        TelegramLogger.log(message)

        user = User.find_or_create_by(telegram_username: message.from.username)
        output = Telegram::CommandMessageHandlerService.run!(user: user, message_text: message.text)
        chat_id = message.chat.id

        bot.api.send_message(chat_id: chat_id, text: output)
      rescue StandardError => e
        ErrorLogger.log(e, context: { message_id: message&.message_id, username: message&.from&.username })
      ensure
        begin
          Prometheus::Client::Push.new(
            job: 'money_tracker_bot',
            gateway: Settings.app.metrics.pushgateway_url
          ).add(Prometheus::Client.registry)
        rescue StandardError => _e
          nil
        end
      end
    end
  end
end
