namespace :permits do
  desc 'Get latest permits and update DB'
  task latest: :environment do
    tstart = Time.now
    min_date = tstart.strftime('%FT%T')
    max_date = min_date

    client = SODA::Client.new({:domain => "data.sfgov.org", app_token: ENV['DATA_TOKEN']})
    base_query = {
      "$where" => "permit_start_date<'#{min_date}' AND permit_end_date>'#{max_date}'",
      "$order" => "permit_start_date ASC"
    }

    all_responses = response = client.get("b6tj-gt35", base_query)
    prev_response_count = response.length

    until prev_response_count < 1000
      response = client.get("b6tj-gt35", base_query.merge({ "$offset" => all_responses.length }))
      all_responses += response
      prev_response_count = response.length
      puts "#{prev_response_count} permits fetched from the last API call"
    end

    Permit.mass_create(all_responses)
    Tools::KmlGenerator.generate_from_permits

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end
end
