class CreatePermits < ActiveRecord::Migration
  def change
    create_table :permits do |t|
      t.string :permit_number
      t.string :streetname
      t.string :cross_street_1
      t.string :corss_street_2
      t.string :permit_type
      t.string :agent
      t.string :agent_phone
      t.string :permit_purpose
      t.date :approved_date
      t.string :status
      t.string :cnn
      t.integer :permit_zipcode 
      t.date :permit_start_date
      t.date :permit_end_date
      t.string :permit_address
      t.string :contact
      t.string :inspector
      t.string :curb_ramp_work 
      t.decimal :x
      t.decimal :y
      t.decimal :latitude 
      t.decimal :longitude
    end
  end
end
