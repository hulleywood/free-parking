class Permit < ActiveRecord::Base

  before_save :sanitize_agentphone, :create_contactphone

  @@disallowed_types = ['TableChair', 'Display']

  def self.mass_create(permit_datas)
    permit_datas.each do |permit_data|
      unless @@disallowed_types.include?(permit_data[:permit_type])
        num = Permit.where(
          longitude: permit_data[:longitude],
          latitude: permit_data[:latitude]
        ).size
        Permit.create_from_api_data(permit_data) if num == 0
      end
    end
  end

  def self.create_from_api_data(data)
    params = {}
    permitted_params = Permit.column_names.reject{|column| column == 'id'}
    data.to_hash.each do |k, v|
      if permitted_params.include?(k) && v.present?
        params[k] = v
      end
    end

    unless create(params)
      Rails.logger.error "Problem creating permit: #{data[:permit_number]}"
    end
  end

  def self.json_fields
    "
      id,
      permit_number,
      permit_type,
      agentphone,
      agent,
      contact,
      contactphone,
      permit_purpose,
      latitude,
      longitude,
      streetname,
      cross_street_1,
      cross_street_2
    "
  end

  def map_label
    "#{self.permit_number} (#{self.permit_type})"
  end

  def map_html
    str = "<p><strong>Agent Phone:</strong> <a href='tel:#{agentphone}'>#{agentphone}</a></p>"
    if agentphone != contactphone && contactphone.present? && contact.downcase != 'refer to agent'
      str << "<p><strong>Contact Phone:</strong> <a href='tel:#{contactphone}'>#{contactphone}</a></p>"
      str << "<p><strong>24/7 Contact:</strong> #{self.contact}</p>"
    end

    str << "<p><strong>Agent:</strong> #{agent}</p>"
    str << "<p><strong>Purpose:</strong> #{permit_purpose}</p>"

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

  def ready_json
    data = attributes
    data[:type] = self.class.to_s
    data
  end
end
