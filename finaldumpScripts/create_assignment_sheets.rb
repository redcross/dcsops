data_loc = ARGV[0]

columns = [
  ["person", ->(r){r.person.full_name if r.person}],
  ["incident",->(r){r.incident.incident_number if r.incident}],
  ["role",],
  ["response",],
  ["created_at",],
  ["updated_at",],
  ["was_flex",],
  ["driving_distance",],
  ["dispatched_at",],
  ["on_scene_at",],
  ["departed_scene_at",],
]

Roster::Region.all.each{|region|
#Roster::Region.where(name: "Illinois").each{|region|
  CSV.open(data_loc + "/" + region.name + ".csv", "w") do |csv|
    csv << columns.map(&:first)
    region.incidents.order(:date, :id).each{|incident|
      incident.all_responder_assignments.each{|r|
        data = columns.map{|col|
          if col.size == 1
            r[col[0]]
          else
            col[1].call r
          end
        }
        csv << data
      }
    }
  end
}
