require 'pry'
require_relative 'politicians'
$db = SQLite3::Database.new "politician_data.db"


class Legislators
  
  HEADERS = ['id', 'title', 'name', 'party', 'state', 'grade_1996', 'grade_current', 
              'years_in_congress', 'dw1_score']

  attr_reader :all_politicians

  def initialize(db_file)
    @all_politicians = load_politicians(db_file)
  end

  def load_politicians(db_file)
    politicians_db = $db.execute("SELECT * FROM politicians;")
    politicians_db.map { |row| row_to_object(row) }    
  end

  def row_to_object(row)
    Politician.new(Hash[HEADERS.zip(row)])
  end

  def political_extremism
    democrat_dw1 = (dw1_averager(/d/i) * 100.0).floor.abs
    republican_dw1 = (dw1_averager(/r/i) * 100.0).floor.abs

    puts "Democrats #{democrat_dw1}% Political Extremism Index, 
        Republicans #{republican_dw1}% Political Extremism Index"
  end

  def dw1_averager(party)
    total_dw1 = all_politicians.inject(0.0) do |sum, politician| 
      if politician.party =~ party && !politician.dw1_score.nil?
        sum + politician.dw1_score.to_f
      else
        sum
      end
    end
    total_dw1 / all_politicians.count { |politician| politician.party =~ party }
    # binding.pry
  end

  def ten_most_liberal_democrats
    democrats = @all_politicians.select { |politician| politician.party =~ /d/i }
    democrats.sort_by! { |politician| politician.dw1_score }
    democrats[0..9]
  end

  def ten_most_conservative_republicans
    republicans = @all_politicians.select { |politician| politician.party =~ /r/i }
    republicans.sort_by! { |politician| politician.dw1_score ? politician.dw1_score : 0}
    republicans.reverse!
    republicans[0..9]
  end

  def update_most_liberal_titles
    ten_most_liberal_democrats.each { |politician| politician.title = 'Liberal Lefty' }
  end

  def update_most_conservative_titles
    ten_most_conservative_republicans.each { |politician| politician.title = 'Right Winger' }
  end

  def list_by_years_in_congress
    all_politicians.sort_by do |politician|
      politician.years_in_congress
    end
  end

  def print_list(list = @all_politicians)
    list.each { |politician| puts politician }
  end

  def truncate_location
    @all_politicians.each { |politician| politician.truncate_location! }
  end

  def update_title
    @all_politicians.each { |politician| politician.update_title! }
  end

  def save_all
    @all_politicians.each {|politician| politician.update_db }
  end

end

legislators = Legislators.new('politician_data.db')
binding.pry
