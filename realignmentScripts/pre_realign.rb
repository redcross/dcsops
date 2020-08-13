puts "VC Positions: " + Roster::VcPosition.count.to_s
puts "VC Position Configurations: " + Roster::VcPositionConfiguration.count.to_s
puts "Positions: " + Roster::Position.count.to_s
puts "Dispatch Configs: " + Scheduler::DispatchConfig.count.to_s
puts "Response Territories: " + Incidents::ResponseTerritory.count.to_s
puts "Notification Role Configurations: " + Incidents::Notifications::RoleConfiguration.count.to_s

Roster::CapabilityMembership.delete_all
Roster::VcPositionConfiguration.delete_all
Roster::VcPosition.delete_all
Roster::Position.delete_all
Roster::PositionMembership.delete_all
Roster::ShiftTerritoryMembership.delete_all
Scheduler::DispatchConfig.delete_all
Incidents::ResponseTerritory.delete_all
Roster::ShiftTerritory.update_all enabled: false
Scheduler::Shift.update_all shift_ends: DateTime.yesterday
Scheduler::ShiftTime.update_all enabled: false
Incidents::Notifications::RoleConfiguration.delete_all
