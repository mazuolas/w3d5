require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...

    param_str = []
    params.each do |key, val|
      param_str << "#{key.to_s} = ?"
    end
    param_str = param_str.join(" AND ")
    results = DBConnection.execute(<<-SQL, params.values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{param_str}
    SQL
    results.map { |result| self.send(:new, result)}
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
