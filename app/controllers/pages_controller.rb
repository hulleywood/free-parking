class PagesController < ApplicationController
  def index; end

  def permit_kml
    render inline: "public/permit.kml", :content_type => 'application/xml'
  end
end
