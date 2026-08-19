class ChangeOrganisationsDescriptionToText < ActiveRecord::Migration[7.1]
  def up
    change_column :organisations, :description, :text
  end

  def down
    change_column :organisations, :description, :string
  end
end
