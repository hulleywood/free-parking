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

  def map_label
    "#{self.permit_type} (#{self.permit_number})"
  end

  def map_html
    phone = self.contact.present? ? self.contact : self.agentphone

    <<-eos
      <![CDATA[
        <h1><strong>Agent Phone:</strong> #{self.agentphone}</h1>
        <h1><strong>24/7 Contact:</strong> #{self.contact}</h1>
        <h1><strong>Agent:</strong> #{self.agent}</h1>
        <h1><strong>Purpose:</strong> #{self.permit_purpose}</h1>
      ]]>
    eos
  end
end
