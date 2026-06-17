namespace :fields do
  desc 'Generate values for the industry field'
  task industry: :environment do
    industry_choice = Choice.find_or_initialize_by(name: 'industry_type') do |choice|
      choice.description = 'Industry type'
    end

    industries = IndustryService.fetch_industries
    industry_choice.choice_items.destroy_all
    industry_choice.save if industry_choice.new_record? || industry_choice.changed?

    industries['content'].each do |industry|
      industry_choice.choice_items.create(name: industry['label'])
    end

    # Save the choice only if it's new or modified
    industry_choice.save if industry_choice.changed?

    puts "Industry types have been updated successfully."
  end
end
