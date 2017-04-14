require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
    SELECT
      *
    FROM
      #{table_name}
    SQL

  end

  def self.finalize!
    columns.each do |col|
      define_method(col.to_s) do
        attributes[col]
      end
      define_method("#{col.to_s}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= name.to_s.tableize
  end

  def self.all
    # ...
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    # ...
    results.map do |result|
      self.send(:new, result)
    end
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    return nil if result.empty?
    self.send(:new, result.first)
  end

  def initialize(params = {})
    # ...
    params.each do |key, value|
      raise "unknown attribute '#{key.to_s}'" unless self.class.columns.include?(key.to_sym)
        self.send("#{key}=", value)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    @attributes.values
  end

  def insert
    # ...
    col_names = self.class.columns.map(&:to_s)
    q_marks = []
    (col_names.length - 1).times { q_marks << "?" }
    q_marks = q_marks.join(", ")
    col_names = col_names[1..-1].join(", ")

    DBConnection.execute(<<-SQL, attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{q_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    set_str = self.class.columns.map(&:to_s)
    set_str = set_str[1..-1].join(" = ?, ") + " = ?"

    DBConnection.execute(<<-SQL, attribute_values[1..-1])
    UPDATE
      #{self.class.table_name}
    SET
      #{set_str}
    WHERE
      id = #{self.id}
    SQL
  end

  def save
    # ...
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
