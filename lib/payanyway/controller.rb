module Payanyway
  module Controller
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token
    end

    def pay
      service = Payanyway::Response::Pay.new(params)
      service.perform
      service.success? ?
        pay_implementation(service.pretty_params) :
        error_log(service.pretty_params)

      render text: service.result
    end

    def success
      service = Payanyway::Response::Base.new(params)
      Rails.logger.info("Called success payment url for order '#{ service.pretty_params[:order_id] }'")

      success_implementation(service.pretty_params)
    end

    def fail
      service = Payanyway::Response::Base.new(params)
      order_id = service.pretty_params[:order_id]
      Rails.logger.error("Fail paid order '#{ order_id }'")

      fail_implementation(order_id)
    end

    def return
      service = Payanyway::Response::Base.new(params)
      order_id = service.pretty_params[:order_id]
      Rails.logger.info("Return from payanyway. Order '#{ order_id }'")

      return_implementation(order_id)
    end

    def in_progress
      service = Payanyway::Response::Base.new(params)
      order_id = service.pretty_params[:order_id]
      Rails.logger.info("Order '#{ order_id }' in progress")

      in_progress_implementation(order_id)
    end

    private

    def error_log(params)
      Rails.logger.error("ERROR! Invalid signature for order #{ params[:order_id] }. Params: #{ params.inspect }")
    end

    def pay_implementation(params)
      # Вызывается после успешного прохождения
      # запроса об оплате от payanyway.ru

      Rails.logger.info("Success paid order #{ params[:order_id] }")
    end

    def success_implementation(params)
      # Вызывается после успешной оплаты
      render nothing: true
    end

    def fail_implementation(params)
      # Вызывается после ошибки при оплате
      render nothing: true
    end

    def return_implementation(params)
      # Вызывается при добровольном отказе пользователем от оплаты
      render nothing: true
    end

    def in_progress_implementation(params)
      # Вызывается после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств
      render nothing: true
    end
  end
end
