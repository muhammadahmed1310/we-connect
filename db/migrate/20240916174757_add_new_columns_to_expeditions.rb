
class AddNewColumnsToExpeditions < ActiveRecord::Migration[7.1]
  def change
    add_column :expeditions, :designation, :string
    add_column :expeditions, :pre_expedition_member_agreement, :boolean, default: false
    add_column :expeditions, :onboarded_to_online_platform, :boolean, default: false
    add_column :expeditions, :communication_project_plan, :boolean, default: false
  end


end
