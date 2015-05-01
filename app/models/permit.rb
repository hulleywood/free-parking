class Permit < ActiveRecord::Base

  before_save :sanitize_agentphone, :create_contactphone

  @@disallowed_types = ['TableChair', 'Display']

  def self.mass_create(permit_datas)
    permit_datas.each do |permit_data|
      unless @@disallowed_types.include?(permit_data[:permit_type])
        permits = Permit.where(permit_number: permit_data[:permit_number])
        if permits.present?
          dup = false
          #permits.each do |db_permit|
          #  if (permit_data[:streetname] == db_permit.streetname &&
          #      permit_data[:cross_street_1] == db_permit.cross_street_1 &&
          #      permit_data[:cross_street_2] == db_permit.cross_street_2) ||
          #     (permit_data[:longitude] == db_permit.longitude &&
          #      permit_data[:latitude] == db_permit.latitude)
          #    dup = true
          #  end
          #end
          Permit.create_from_api_data(permit_data) unless dup
        else
          Permit.create_from_api_data(permit_data) 
        end
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
    " permit_number,
      permit_type,
      agentphone,
      agent,
      contact,
      contactphone,
      permit_purpose,
      latitude,
      longitude"
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
end
