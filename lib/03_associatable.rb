require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]

    @primary_key ||= :id
    @foreign_key ||= (name.to_s + "_id").to_sym
    @class_name ||= name.to_s.camelcase

  end
end

class HasManyOptions < AssocOptions



  def initialize(name, self_class_name, options = {})
    # ...
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]

    @primary_key ||= :id
    @foreign_key ||= (self_class_name.to_s.downcase + "_id").to_sym
    @class_name ||= name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, option = {})
    # ...
    define_method(name) do
      options = BelongsToOptions.new(name, option)
      foreign_key_val = self.send(options.foreign_key)

      options.model_class.where({options.primary_key => foreign_key_val}).first
    end
  end

  def has_many(name, option = {})
    # ...

    define_method(name) do
      options = HasManyOptions.new(name, self.class, option)
      foreign_key_val = self.send(options.primary_key)

      options.model_class.where({options.foreign_key => foreign_key_val})
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
