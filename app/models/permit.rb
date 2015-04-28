class Permit < ActiveRecord::Base

  before_save :sanitize_agentphone, :create_contactphone

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
    if agentphone != contactphone
      <<-eos
        <h1><strong>Agent Phone:</strong> <a href="tel:#{agentphone}">#{agentphone}</a></h1>
        <h1><strong>Contact Phone:</strong> <a href="tel:#{contactphone}">#{contactphone}</a></h1>
        <h1><strong>24/7 Contact:</strong> #{self.contact}</h1>
        <h1><strong>Agent:</strong> #{self.agent}</h1>
        <h1><strong>Purpose:</strong> #{self.permit_purpose}</h1>
      eos
    else
      <<-eos
        <h1><strong>Agent Phone:</strong> <a href="tel:#{agentphone}">#{agentphone}</a></h1>
        <h1><strong>24/7 Contact:</strong> #{self.contact}</h1>
        <h1><strong>Agent:</strong> #{self.agent}</h1>
        <h1><strong>Purpose:</strong> #{self.permit_purpose}</h1>
      eos
    end
  end

  def sanitize_agentphone
    phone_number = Phoner::Phone.parse(agentphone)
    if phone_number.present?
      self.agentphone = phone_number.format(:default_with_extension).gsub(/x/, ',')
    end
  end

  def create_contactphone
    phone_number = Phoner::Phone.parse(contact)
    if phone_number.present?
      self.contactphone = phone_number.format(:default_with_extension).gsub(/x/, ',')
    end
  end
end
