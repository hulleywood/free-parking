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
    str = "<![CDATA["
    str << "<p><strong>Agent Phone:</strong> <a href='tel:#{agentphone}'>#{agentphone}</a></p>"
    if agentphone != contactphone && contactphone.present? && contact.downcase != 'refer to agent'
      str << "<p><strong>Contact Phone:</strong> <a href='tel:#{contactphone}'>#{contactphone}</a></p>"
      str << "<p><strong>24/7 Contact:</strong> #{self.contact}</p>"
    end

    str << "<p><strong>Agent:</strong> #{agent}</p>"
    str << "<p><strong>Purpose:</strong> #{permit_purpose}</p>"
    str << "]]>"

    str
  end

  def sanitize_agentphone
    phone_number = Phoner::Phone.parse(agentphone)
    if phone_number.present?
      if phone_number.extension.present?
        self.agentphone = phone_number.format(:default_with_extension).gsub(/x/, ',')
      else
        self.agentphone = phone_number.format(:default_with_extension).gsub(/x/, '')
      end
    end
  end

  def create_contactphone
    phone_number = Phoner::Phone.parse(contact)
    if phone_number.present?
      if phone_number.extension.present?
        self.contactphone = phone_number.format(:default_with_extension).gsub(/x/, ',')
      else
        self.contactphone = phone_number.format(:default_with_extension).gsub(/x/, '')
      end
    end
  end
end
