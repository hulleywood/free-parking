class CreateTemporarySigns < ActiveRecord::Migration
  def change
    create_table :temporary_signs do |t|
      t.string  :address
      t.string  :case_id
      t.string  :category
      t.date    :opened
      t.date    :updated
      t.string  :request_details
      t.string  :request_type
      t.string  :responsible_agency
      t.decimal :latitude 
      t.decimal :longitude
    end
  end
end
