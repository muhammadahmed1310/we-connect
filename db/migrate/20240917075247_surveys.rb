# frozen_string_literal: true

class Surveys < ActiveRecord::Migration[7.1]
  def change
    create_table :surveys do |t|
      t.string :name
      t.string :survey_type
      t.string :survey_status_type
      t.string :version
      t.integer :author_id
      t.string :notes, limit: 4096
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    create_table :survey_pages do |t|
      t.belongs_to :survey
      t.string :name
      t.string :survey_page_type
      t.string :title
      t.text :content
      t.integer :position

      t.timestamps
    end

    create_table :survey_questions do |t|
      t.belongs_to :survey_page
      t.string :name
      t.string :label
      t.string :survey_question_item_type
      t.string :question_class
      t.integer :text_lines
      t.integer :min_value
      t.integer :max_value
      t.string :choice_name
      t.boolean :multiple_answers, default: false, null: false
      t.text :hint
      t.integer :position

      t.string :notes, limit: 4096
      t.timestamps
    end

    create_table :survey_responses do |t|
      t.belongs_to :survey
      t.belongs_to :user
      t.belongs_to :expedition
      t.belongs_to :activity
      t.datetime :started_at
      t.string :survey_response_status_type
      t.integer :last_viewed_page_id

      t.timestamps
    end

    create_table :survey_answers do |t|
      t.belongs_to :survey_response
      t.belongs_to :survey_question
      t.text :string_answer
      t.string :choice_answer, limit: 2000
      t.integer :number_answer

      t.timestamps
    end

    create_table :survey_expeditions do |t|
      t.belongs_to :survey
      t.belongs_to :expedition
      t.string :survey_expedition_type
      t.timestamps
    end

    create_table :survey_activities do |t|
      t.belongs_to :survey
      t.belongs_to :activity
      t.string :survey_activity_type
      t.timestamps
    end
  end
end
