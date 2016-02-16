class Roster::RcoIdImporter
  def initialize(csv_contents)
    @contents = csv_contents
  end

  def import
    csv = CSV.parse @contents

    csv.each do |row|
      next unless row[2] # Sometimes the emails come in with an extra line.

      vc_id = row[0]
      rco_id = row[2].gsub(/[^\d]+/, '')

      Roster::Person.where(vc_id: vc_id).update_all rco_id: rco_id
    end
  end
end
