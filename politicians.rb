require 'sqlite3'
require 'pry'

$db = SQLite3::Database.new "politician_data.db"

class Politician

  attr_accessor :name, :party, :state, :grade_1996, :grade_current, 
              :years_in_congress, :dw1_score, :id, :title
  attr_reader :headers
  
  @@headers = ['id', 'title', 'name', 'party', 'state', 'grade_1996', 'grade_current', 
              'years_in_congress', 'dw1_score']

  def initialize(params)
    @id = params.fetch('id', nil)
    @name = params.fetch('name')
    @party = params.fetch('party')
    @state = params.fetch('state')
    @grade_1996 = params.fetch('grade_1996')
    @grade_current = params.fetch('grade_current')
    @years_in_congress = params.fetch('years_in_congress')
    @title = params.fetch('title', '')
    @dw1_score = params.fetch('dw1_score')

  end

  def add_to_db
    query = <<-SQL
        INSERT INTO politicians
        VALUES (NULL,?,?,?,?,?,?,?,?);
      SQL
    $db.execute(query, title, name, party, state, grade_1996, grade_current, years_in_congress, dw1_score)
  end

  def update_db
    query = <<-SQL
      UPDATE politicians
      SET title = ?, name = ?, party = ?, state = ?, grade_1996 = ?, grade_current = ?, years_in_congress = ?, dw1_score = ?
      WHERE id = ?;
      SQL
    $db.execute(query, title, name, party, state, grade_1996, 
                grade_current, years_in_congress, dw1_score, id)
  end

  def delete_from_table
    $db.execute("DELETE FROM politicians WHERE id = ?;", id)
  end

  def truncate_location!
    self.state = state[0..1] unless state.nil?
  end

  def update_title!
    house = name.match(/(rep\.\s|sen\.\s)/i)[0]
    name.gsub!(/(rep\.\s|sen\.\s)/i, '')
    # binding.pry
    unless house.nil?
      self.title = house.match(/rep\.\s/i) ? 'Representative' : 'Senator'
    end
  end

  def to_s
    "#{title} #{name}: #{party}, #{state}; grade 1996: #{grade_1996}, 
    years in congress: #{years_in_congress}, dw1_score #{dw1_score}"
  end

end
