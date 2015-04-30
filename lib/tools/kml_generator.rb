module Tools

  class KmlGenerator
    require 'nokogiri'

    @kml = ::Nokogiri::XML::Builder.new do |xml|
      xml.kml(:xmlns => "http://www.opengis.net/kml/2.2")
    end

    @doc = Nokogiri::XML::Document.new

    def self.generate_from_permits
      file_path = "public/permits.kml"
      permits = Permit.all
      ::Nokogiri::XML::Builder.with(@kml.doc.at('kml')) do |xml|
        xml.Document do
          permits.each do |permit|
            xml.Placemark do
              create_placemark_from_permit(xml, permit)
            end
          end
        end
      end

      File.write(file_path, @kml.to_xml)
    end

    def self.create_placemark_from_permit(xml, permit)
      xml.name permit.map_label
      xml.description do
        xml.cdata permit.map_html
      end
      xml.Point do
        xml.coordinates "#{permit.longitude.to_f},#{permit.latitude.to_f},0"
      end
    end

  end
end
