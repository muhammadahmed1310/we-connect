# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_config
      @search_config ||= { columns: [], associations: {}, virtual: {} }
    end

    def searchable_columns(*cols)
      search_config[:columns] = cols.flatten.map!(&:to_sym)
    end

    # e.g. searchable_association :user_role_types, :name
    def searchable_association(assoc, *cols)
      search_config[:associations][assoc.to_sym] = cols.flatten.map!(&:to_sym)
    end

    # e.g. searchable_virtual :full_name { |t| Arel::Nodes::NamedFunction.new('CONCAT_WS', [' ', t[:first_name], t[:last_name]]) }
    def searchable_virtual(name, &block)
      search_config[:virtual][name.to_sym] = block
    end

    # case-insensitive LIKE on any Arel attribute or expression
    def ci_match(expr, qd)
      Arel::Nodes::NamedFunction.new('LOWER', [expr]).matches("%#{qd}%")
    end

    def apply_search(relation, term)
      return relation if term.blank?

      q  = sanitize_sql_like(term.to_s)
      qd = q.downcase

      arel = self.arel_table
      preds = []

      # direct columns
      search_config[:columns].each do |col|
        preds << ci_match(arel[col], qd)
      end

      # virtual expressions (e.g., full_name)
      search_config[:virtual].each_value do |builder|
        expr = builder.call(arel)                  # returns an Arel node/expression
        preds << ci_match(expr, qd)
      end

      # associations (one hop)
      joins_needed = []
      search_config[:associations].each do |assoc, cols|
        reflection = reflect_on_association(assoc)
        next unless reflection
        joins_needed << assoc unless relation.joins_values.include?(assoc)
        t = reflection.klass.arel_table
        cols.each { |c| preds << ci_match(t[c], qd) }
      end

      relation = relation.left_joins(*joins_needed) if joins_needed.any?
      return relation if preds.empty?

      relation.where(preds.reduce { |acc, p| acc.or(p) })
    end
  end
end
