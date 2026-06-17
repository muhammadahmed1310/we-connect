# app/models/organisation_user.rb
class OrganisationUser < ApplicationRecord
  belongs_to :organisation
  belongs_to :user

  validates :organisation_id, uniqueness: { scope: :user_id }
end
