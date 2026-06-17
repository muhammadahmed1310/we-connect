class SurveyExpedition < ApplicationRecord
  belongs_to :survey
  belongs_to :expedition

end
