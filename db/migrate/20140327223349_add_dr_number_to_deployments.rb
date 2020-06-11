class AddDrNumberToDeployments < ActiveRecord::Migration
  class Deployment < ApplicationRecord
    self.table_name = 'incidents_deployments'
  end

  def change
    add_column :incidents_deployments, :dr_number, :string

    say_with_time "Update DR Titles" do
      Deployment.find_each do |dep|
        number, name = dep.dr_name.split ' ', 2
        number = number.gsub '-20', '-'
        dep.dr_number = number
        dep.dr_name = name
        dep.save!
      end
    end
  end
end
