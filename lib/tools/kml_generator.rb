module Tools

  class KmlGenerator
    require 'nokogiri'

    @kml = ::Nokogiri::XML::Builder.new do |xml|
      xml.kml(:xmlns => "http://www.opengis.net/kml/2.2")
    end


    def self.generate_from_permits
      puts '*'*80
      file_path = "public/permits.kml"
      puts file_path
      permits = Permit.all.first(100)
      ::Nokogiri::XML::Builder.with(@kml.doc.at('kml')) do |xml|
        permits.each do |permit|
          xml.Placemark do
            create_placemark_from_permit(xml, permit)
          end
        end
      end

      File.write(file_path, @kml.to_xml)
    end

    def self.create_placemark_from_permit(xml, permit)
      xml.name permit.map_label
      xml.description permit.map_html
      xml.Point do
        xml.coordinates "#{permit.longitude.to_f},#{permit.latitude.to_f},0"
      end
    end
  end
end
