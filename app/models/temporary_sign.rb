class TemporarySign < ActiveRecord::Base

  def self.mass_create(data)
    data.each do |sign_data|
      TemporarySign.create_from_api_data(sign_data)
    end
  end

  def self.create_from_api_data(data)
    params = {}

    permitted = [
      'address',
      'case_id',
      'category',
      'opened',
      'updated',
      'request_details',
      'request_type',
      'responsible_agency'
    ]

    data.to_hash.each do |k, v|
      if permitted.include?(k) && v.present?
        params[k] = v
      end
    end

    if data[:point].present?
      params[:latitude] = data[:point][:coordinates].last
      params[:longitude] = data[:point][:coordinates].first

      unless create(params)
        Rails.logger.error "Problem creating temporary sign: #{data[:case_id]}"
      end
    end
  end

  def self.json_fields
    "
      id,
      address,
      case_id,
      category,
      opened,
      updated,
      request_details,
      request_type,
      responsible_agency,
      latitude,
      longitude
    "
  end

  def ready_json
    data = attributes
    data[:type] = self.class.to_s
    data
  end
end
