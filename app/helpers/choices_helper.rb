# app/helpers/choices_helper.rb
module ChoicesHelper
  # value: :id for filters (IDs in params), or :name for form fields
  def choice_options(name, value: :id)
    items = Choice.select_options_for(name.to_s.singularize, raw: true)
    items.map { |ci| [camel_label(ci.name), value == :id ? ci.id : ci.name] }
         .sort_by { |lbl, _| lbl.downcase }
  end
end
