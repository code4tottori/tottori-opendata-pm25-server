class Record < ApplicationRecord

  def self.last_updated_at
    Record.order(:updated_at).select(:updated_at).last&.updated_at
  end

end
