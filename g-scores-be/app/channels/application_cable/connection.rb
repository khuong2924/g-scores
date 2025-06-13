module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      # Cho phép tất cả các kết nối
      logger.add_tags 'ActionCable'
    end

    private

    def reject_unauthorized_connection
      logger.error "WebSocket connection rejected"
      super
    end
  end
end 