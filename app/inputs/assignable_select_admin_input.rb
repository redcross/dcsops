require_relative 'assignable_select_input'
class AssignableSelectAdminInput < Formtastic::Inputs::SelectInput
  include AssignableSelect
end