puts "VC Positions: " + Roster::VcPosition.count.to_s
puts "VC Position Configurations: " + Roster::VcPositionConfiguration.count.to_s
puts "Positions: " + Roster::Position.count.to_s
puts "Dispatch Configs: " + Scheduler::DispatchConfig.count.to_s
puts "Response Territories: " + Incidents::ResponseTerritory.count.to_s
puts "Shift Assignments: " + Scheduler::ShiftAssignment.count.to_s
puts "Shifts: " + Scheduler::Shift.count.to_s
puts "Shift Territories: " + Roster::ShiftTerritory.count.to_s
puts "Shift Times: " + Scheduler::ShiftTime.count.to_s

Roster::CapabilityMembership.delete_all
Roster::VcPositionConfiguration.delete_all
Roster::VcPosition.delete_all
Roster::Position.delete_all
Roster::PositionMembership.delete_all
Roster::ShiftTerritoryMembership.delete_all
Scheduler::DispatchConfig.delete_all
Incidents::ResponseTerritory.delete_all
Scheduler::ShiftAssignment.delete_all
Scheduler::Shift.delete_all
Roster::ShiftTerritory.delete_all
Scheduler::ShiftTime.delete_all

