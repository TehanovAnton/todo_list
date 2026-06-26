# frozen_string_literal: true

module Telegram
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def create
      update = JSON.parse(request.body.read)
      msg    = update['message']

      user   = User.find_or_create_by(telegram_username: msg.dig('from', 'username'))
      output = Telegram::CommandMessageHandlerService.run!(user: user, message_text: msg['text'])

      render json: { ok: true, text: output }, status: :ok
    rescue StandardError => e
      ErrorLogger.log(e, context: { source: 'webhook' })
      head :unprocessable_entity
    end
  end
end
