require 'active_support/concern'

# Concern to allow a model to be scoped on certain attributes with inferred choices
module Scopable

  extend ActiveSupport::Concern

  included do
    class_attribute :_scopes
    class_attribute :_scopes_hash, default: {}

    def scopes_names
      self.class._scopes_hash.keys
    end

    def scopes_hash
      self.class._scopes_hash
    end
  end

  class_methods do
    def we_scopes(*args)
      self._scopes = args
      args.each do |scope|
        _scopes_hash[scope] = {name: scope, choices: Choice.infer_choices(scope)}
        scope scope, ->(type) { where(scope => type) }
      end
    end
  end

end
