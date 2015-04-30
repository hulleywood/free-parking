module Tools

  class JsonGenerator

    def self.generate_from_permits
      file_path = "public/permits.json"
      permits = Permit.select(Permit.json_fields)
      File.write(file_path, permits.to_json)
    end

  end
end
