# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # For now, we'll allow all connections
      # In production, you should implement proper authentication
      true
    end
  end
end

# Configure Action Cable
Rails.application.config.action_cable.mount_path = '/cable' 