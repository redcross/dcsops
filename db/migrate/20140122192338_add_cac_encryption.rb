class AddCacEncryption < ActiveRecord::Migration
  class Case < ApplicationRecord
    self.table_name = :incidents_cases

    encrypt_with_public_key :encrypted_cac, public_key: ENV['CAC_PUBLIC_KEY'], private_key: ENV['CAC_PRIVATE_KEY'], symmetric: :never

    def normalize_cac_number
      if cac_number
        self.cac_number = cac_number.gsub(/\D/, '')
      end
    end

    def set_masked_cac
      if cac_number.present?
        pan_first = cac_number[0..3]
        pan_second = cac_number[4..5]
        last_4 = cac_number[-4..-1]
        self.cac_masked = "#{pan_first}-#{pan_second}xx-xxxx-#{last_4}"
      else
        self.cac_masked = nil
      end
    end
  end

  def change
    add_column :incidents_cases, :cac_masked, :string
    add_column :incidents_cases, :encrypted_cac, :binary

    say_with_time "Mask PANs and encrypt" do
      Case.find_each do |kase|
        kase.normalize_cac_number
        kase.set_masked_cac
        kase.encrypted_cac = kase.cac_number
        kase.save!
      end
    end

    remove_column :incidents_cases, :cac_number
    rename_column :incidents_cases, :encrypted_cac, :cac_number
  end
end
