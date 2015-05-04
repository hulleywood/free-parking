namespace :signs do
  desc 'Remove old signs'
  task remove_old: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to remove all temporary signs"

    TemporarySign.destroy_all

    tend = Time.now
    Rails.logger.info "Completed removing old temporary signs in #{tend - tstart} seconds"
  end

  desc 'Get latest signs and update db'
  task create_temporary_signs: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to add new temporary signs"

    client = SODA::Client.new({:domain => "data.sfgov.org", app_token: ENV['DATA_TOKEN']})
    query = "status='Open' AND responsible_agency='SFMTA - Temporary Sign Request Queue'" 
    base_query = {
      "$where" => query,
      "$order" => "opened DESC"
    }

    all_responses = response = client.get("ktji-gk7t", base_query)
    prev_response_count = response.length

    until prev_response_count < 1000
      response = client.get("ktji-gk7t", base_query.merge({ "$offset" => all_responses.length }))
      all_responses += response
      prev_response_count = response.length
      Rails.logger.info "#{prev_response_count} signs fetched from the last API call"
    end

    TemporarySign.mass_create(all_responses)

    Rails.logger.info "Total signs from API: #{all_responses.length}"
    Rails.logger.info "Total sign in db: #{TemporarySign.all.size}"

    tend = Time.now
    Rails.logger.info "Completed adding new signs in #{tend - tstart} seconds"
  end

  desc 'Create a json file with sign data'
  task create_json: :environment do
    tstart = Time.now
    Rails.logger.info "Starting to create json file"

    Tools::JsonGenerator.generate_from_temporary_signs

    tend = Time.now
    Rails.logger.info "Completed creating json file in #{tend - tstart} seconds"
  end
end
