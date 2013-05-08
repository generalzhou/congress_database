require 'sqlite3'
require 'csv'
require_relative 'politicians'
$db = SQLite3::Database.new "politician_data.db"

class Parser

  attr_reader :headers

  def load(file_name)
    CSV.foreach(file_name) do |row|
      if row.first == 'name'
        @headers = row
        create_db
      else 
        create_politician(row)
      end
    end
  end

  def create_db
    
    $db.execute("DROP TABLE IF EXISTS politicians;")
    
    $db.execute(
      <<-SQL
        CREATE TABLE IF NOT EXISTS politicians (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title VARCHAR(64) DEFAULT '',
          name VARCHAR(64) NOT NULL,
          party CHAR NOT NULL,
          state VARCHAR(2) NOT NULL,
          grade_1996 DECIMAL DEFAULT 0,
          grade_current DECIMAL DEFAULT 0,
          years_in_congress INTEGER DEFAULT 0,
          dw1_score DECIMAL DEFAULT '0'
          );
      SQL
      )
  end

  def create_politician(row)
    params = Hash[headers.zip(row)]
    politician = Politician.new(params)
    politician.add_to_db
  end

end

parse = Parser.new
parse.load('politician_data.csv')
