module Tools

  class JsonGenerator

    def self.generate_from_permits
      file_path = "public/permits.json"
      data = Permit.select(Permit.json_fields)
      pre_json = data.collect(&:ready_json)
      File.write(file_path, pre_json.to_json)
    end

    def self.generate_from_temporary_signs
      file_path = "public/temporary_signs.json"
      data = TemporarySign.select(TemporarySign.json_fields)
      pre_json = data.collect(&:ready_json)
      File.write(file_path, pre_json.to_json)
    end

  end
end
