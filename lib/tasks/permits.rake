namespace :permits do
  desc 'Remove permits that have expired'
  task remove_old: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to remove old permits"

    min_date = tstart.strftime('%FT%T')
    max_date = min_date
    old_permits = Permit.where("permit_end_date < ?", Time.now.strftime('%F'))
    Rails.logger.info "Destroying #{old_permits.size} permits"
    old_permits.destroy_all

    tend = Time.now
    Rails.logger.info "Completed removing old permits in #{tend - tstart} seconds"
  end

  desc 'Get latest permits and update DB'
  task create_new: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to add new permits"

    min_date = tstart.strftime('%FT%T')
    max_date = min_date
    client = SODA::Client.new({:domain => "data.sfgov.org", app_token: ENV['DATA_TOKEN']})
    query = "permit_start_date<'#{min_date}' AND permit_end_date>'#{max_date}'" 
    query << " AND permit_type!='TableChair' AND permit_type!='Display'"
    base_query = {
      "$where" => query,
      "$order" => "permit_start_date ASC"
    }

    all_responses = response = client.get("b6tj-gt35", base_query)
    prev_response_count = response.length

    until prev_response_count < 1000
      response = client.get("b6tj-gt35", base_query.merge({ "$offset" => all_responses.length }))
      all_responses += response
      prev_response_count = response.length
      Rails.logger.info "#{prev_response_count} permits fetched from the last API call"
    end

    Permit.mass_create(all_responses)
    Rails.logger.info "Total permits from API: #{all_responses.length}"
    Rails.logger.info "Total permits in db: #{Permit.all.size}"

    tend = Time.now
    Rails.logger.info "Completed adding new permits in #{tend - tstart} seconds"
  end

  desc 'Create a kml file with permit data'
  task create_kml: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to create kml file"

    Tools::KmlGenerator.generate_from_permits

    tend = Time.now
    Rails.logger.info "Completed creating kml file in #{tend - tstart} seconds"
  end

  desc 'Create a json file with permit data'
  task create_json: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to create json file"

    Tools::JsonGenerator.generate_from_permits

    tend = Time.now
    Rails.logger.info "Completed creating json file in #{tend - tstart} seconds"
  end
end
