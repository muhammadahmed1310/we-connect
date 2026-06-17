class UserRoleChoiceItem < ApplicationRecord

  belongs_to :user
  belongs_to :choice_item
  validates :choice_item_id, uniqueness: { scope: :user_id }

end
