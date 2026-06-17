class Choice < ApplicationRecord
  has_many :choice_items, dependent: :destroy
  include PaperTrailCustom
  has_paper_trail save_object_changes: true

  def paper_trail_attributes_for_destroy
    { name: self.name }
  end



  def self.union_options_for(*choice_names)
    ChoiceItem
      .joins(:choice)
      .where(choices: { name: choice_names })
      .distinct
      .pluck(:name, :id)
      .sort_by { |name, _| name.downcase }
  end

  def self.phase_type_options_with_labels
    group_items = ChoiceItem.joins(:choice).where(choices: { name: 'expedition_phase_type_group' })
    solo_items = ChoiceItem.joins(:choice).where(choices: { name: 'expedition_phase_type_solo' })

    (group_items.map { |ci| ["#{ci.name} (Group)", ci.id] } +
      solo_items.map { |ci| ["#{ci.name} (Solo)", ci.id] })
      .sort_by(&:first)
  end

  def self.select_options_for(choice_name, raw: false, add_blank: false, label_as_value: false)
    items = find_by(name: choice_name)&.choice_items
    return [] unless items

    result =
      if raw
        items
      elsif label_as_value
        items.pluck(:name).map { |name| [name.titleize, name] }
      else
        items.pluck(:name, :id)
      end

    result << ['', nil] if add_blank
    result
  end

  def self.task_type_id
    @task_type_id ||= find_by(name: 'activity_type')&.choice_items&.find_by(name: 'task')&.id
  end

  def self.meeting_type_id
    @meeting_type_id || find_by(name: 'activity_type')&.choice_items&.find_by(name: 'meeting')&.id
  end


  # Determine the choices for a reference field
  #
  # * the name can be a field name or an association name
  # * for the moment, we're assuming that the field name is the same as the association name
  #   which may cause problems with fields such as :assigned_user_id
  #
  def self.reference_choices(model, name, parent: nil, add_blank: false)
    # Find the associated model
    assoc = model.reflect_on_association(name.to_s.downcase.pluralize.to_sym)
    assoc ||= model.reflect_on_association(name.to_s.downcase.singularize.to_sym)
    return nil if assoc.nil?
    assoc_model = assoc.klass

    choices = if parent.present?
                assoc_name = assoc_model.name.underscore.pluralize.to_sym
                parent.send(assoc_name).map { |m| [m.name, m.id] }
              else
                assoc_model.all.map { |m| [m.name, m.id] }
              end
    choices = choices.sort_by { |c| c[0].to_s }
    choices << ['', nil] if add_blank
    choices
  end

  # Determine the implied choices for fields based on the name of the field:
  #
  # * fields that end in type will have choices based on the Choice model
  # * fields that end in _id will have choices based on the referenced model
  # * fields that start with is_ will have choices of Yes and No
  #
  def self.infer_choices(name, add_blank: false, parent: nil, parent_value: nil, model:nil)
    if name.ends_with?('Type') || name.ends_with?('_type')
      select_options_for(name, add_blank: add_blank)
    elsif name.ends_with?('_id')
      reference_choices(model, name, parent: parent, add_blank: add_blank)
    elsif name.starts_with?('is_')
      [['Yes', 1], ['No', 0]]
    else
      nil
    end
  end

  def self.sub_records = %w[choice_items]

  def self.table_names = %w[name description choice_items]

  def self.field_names = %w[name description]
end
