class Roster::VcImportData < ApplicationRecord
  belongs_to :region

  def positions_matching regex_str
    regex = Regexp.new(regex_str)
    results = position_data.map do |name, count|
      if regex =~ name
        {name: name, count: count}
      end
    end.compact.sort_by{|row| row[:name] }
  end
end
