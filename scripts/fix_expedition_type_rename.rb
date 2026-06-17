# script/fix_expedition_type_rename.rb
ActiveRecord::Base.transaction do
  puts "Updating expeditions (incl. skeletons) individual → solo…"
  n = Expedition.where(expedition_type: 'individual').update_all(expedition_type: 'solo')
  puts "  Updated #{n} expeditions."

  puts "Fixing ChoiceItem for 'expedition_type'…"
  choice     = Choice.find_by(name: 'expedition_type')
  individual = choice&.choice_items&.find_by(name: 'individual')
  solo       = choice&.choice_items&.find_by(name: 'solo')

  if individual
    if solo
      individual.destroy!
      puts "  Removed legacy 'individual' choice item (solo already exists)."
    else
      cols = { name: 'solo' }
      cols[:label] = 'solo' if individual.attributes.key?('label')
      individual.update_columns(cols)
      puts "  Renamed 'individual' → 'solo'."
    end
  else
    puts "  Nothing to rename; no 'individual' choice item found."
  end

  puts "Done."
end
