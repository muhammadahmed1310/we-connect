module PaperTrailCustom
  extend ActiveSupport::Concern

  included do
    def papertrail_description
      case self
      when User
        "User #{name}"
      when Expedition
        "Expedition #{name}"
      when Activity
        "Task #{name}"
      when ExpeditionUser
        "Expedition User #{user.name}"
      else
        "#{self.class.name} ##{id}"
      end
    end
  end
end
