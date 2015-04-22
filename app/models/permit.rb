class Permit < ActiveRecord::Base

  def self.mass_create(permit_datas)
    permit_datas.each do |permit_data|
      permit = Permit.find_by_permit_number(permit_data[:permit_number])
      unless permit
        puts "No permit record found for #{permit_data[:permit_number]}, creating record..."
        Permit.create_from_api_data(permit_data)
      end
    end
  end

  def self.create_from_api_data(data)
    params = {}
    permitted = Permit.column_names.reject{|column| column == 'id'}
    data.to_hash.each do |k, v|
      if permitted.include?(k) && v.present?
        params[k] = v
      end
    end

    unless create(params)
      Rails.logger.error("Problem creating permit: #{data[:permit_number]}")
      puts "Problem creating permit: #{data[:permit_number]}"
    end
  end
end
