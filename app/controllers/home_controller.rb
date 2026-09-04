class HomeController < ApplicationController

  before_action :authenticate_user!
  def dashboard
    excluded = %w[finished dissemination dissementation] # include the common typo too
    @active_expeditions = Expedition
                            .where(is_skeleton: false)
                            .where.not(expedition_phase_type: excluded)
    @expeditions = Expedition.where(is_skeleton: false)
    # 🔹 Role references
    role_choice = Choice.find_by(name: 'user_role_type')
    role_ids = role_choice.choice_items.index_by(&:name)

    fellow_id      = role_ids['fellow']&.id
    explorer_id    = role_ids['explorer']&.id
    sologoer_id    = role_ids['sologoer']&.id
    basecamper_id  = role_ids['basecamper']&.id

    explorer_role_ids = [fellow_id, explorer_id, sologoer_id, basecamper_id].compact

    # 🔹 Distinct explorer users
    @explorers = User.joins(:user_role_choice_items)
                     .where(user_role_choice_items: { choice_item_id: explorer_role_ids })
                     .distinct

    @explorer_count = @explorers.count

    # 🔹 Explorer breakdown chart (overlapping roles allowed)
    @explorer_roles_breakdown = {
      'Fellow'     => User.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: fellow_id }).distinct.count,
      'Explorer'   => User.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: explorer_id }).distinct.count,
      'Sologoer'   => User.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: sologoer_id }).distinct.count,
      'Basecamper' => User.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: basecamper_id }).distinct.count
    }

    # 🔹 Direct role-based solo vs group count
    @group_count = @explorers.joins(:user_role_choice_items)
                             .where(user_role_choice_items: { choice_item_id: explorer_id }).distinct.count

    @solo_count = @explorers.joins(:user_role_choice_items)
                            .where(user_role_choice_items: { choice_item_id: sologoer_id }).distinct.count

    @fellow_count = @explorers.joins(:user_role_choice_items)
                              .where(user_role_choice_items: { choice_item_id: fellow_id }).distinct.count

    @basecamper_count = if basecamper_id
                          @explorers.joins(:user_role_choice_items)
                                    .where(user_role_choice_items: { choice_item_id: basecamper_id }).distinct.count
                        else
                          0
                        end

    # 🔹 Community users: total users - explorers
    @community_users = User.where.not(id: @explorers.select(:id))

    # 🔹 Community roles chart: count ALL users with any roles
    raw_role_counts = Hash.new(0)
    User.includes(:user_role_types).each do |user|
      user.user_role_types.each { |role| raw_role_counts[role.label] += 1 }
    end

    # 🔹 Merge WE Staff roles into single label
    we_staff_labels = ['Manager', 'Administrator', 'Staff', 'Community Manager', 'Expedition Leader']
    we_staff_total = we_staff_labels.sum { |label| raw_role_counts.delete(label) || 0 }
    raw_role_counts.delete('Fellow')
    raw_role_counts.delete('Explorer')
    raw_role_counts.delete('Sologoer')
    raw_role_counts.delete('Basecamper')
    @community_roles = { 'WE Staff' => we_staff_total }.merge(raw_role_counts)


  end


end
