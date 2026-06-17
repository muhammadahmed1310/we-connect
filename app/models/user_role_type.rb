class UserRoleType < ApplicationRecord

  belongs_to :user
  belongs_to :choice_item
end
